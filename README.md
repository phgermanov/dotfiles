# Dotfiles

A Nix flake that configures the Raspberry Pi home server and a MacBook:

| Config | Machine | Tool |
|---|---|---|
| `phgermanov@pi` | Raspberry Pi 5 home server, Raspberry Pi OS | Home Manager, standalone |
| `macbook16` | MacBook | nix-darwin with Home Manager |

Both get the same zsh setup (oh-my-zsh git plugin, autosuggestions, Starship, fzf, zoxide, direnv)
and the same CLI tools, including Go and Node. Home Manager generates `~/.zshrc`, so the old
hand-written `.zshrc` and Powerlevel10k are gone. No machine sets a global git identity, so every
repo sets its own `user.name` and `user.email`.

App configs stay as plain files under `.config/`. Home Manager symlinks them to this checkout, so
edits apply without a rebuild. The repo must be cloned at `~/dotfiles`.

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, Home Manager, nix-darwin), the machine configs and `lib.mkDarwin` |
| `nix/home/common.nix` | Shell, CLI tools and config links for every machine |
| `nix/home/darwin.nix` | Every Mac: tmux, `~/.local/scripts`, AeroSpace, terminal and editor configs |
| `nix/darwin/common.nix` | macOS system settings for every Mac |
| `nix/hosts/pi.nix` | Pi only: disk-saving overrides and a weekly garbage-collection timer |
| `nix/hosts/macbook16/` | `macbook16` only: AeroSpace and borders casks, Karabiner |

## Other Macs from a private flake

A Mac whose hostname or username shouldn't be public gets its config from a private flake that
takes this one as an input:

```nix
{
  inputs.dotfiles.url = "github:phgermanov/dotfiles/nix";

  outputs =
    { dotfiles, ... }:
    {
      darwinConfigurations.<LocalHostName> = dotfiles.lib.mkDarwin {
        user = "<macOS username>";
        homeModules = [ ./home.nix ]; # Home Manager modules for that Mac only
        darwinModules = [ ]; # nix-darwin modules for that Mac only
      };
    };
}
```

`mkDarwin` adds the shared modules from this repo. That Mac still needs this repo cloned at
`~/dotfiles` for the config symlinks.

## Raspberry Pi

Apply changes:

```sh
home-manager switch --flake ~/dotfiles#phgermanov@pi
```

Set up from scratch:

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
gh repo clone phgermanov/dotfiles ~/dotfiles
nix run home-manager/release-26.05 -- switch -b pre-nix --flake ~/dotfiles#phgermanov@pi
```

The root filesystem is an SD card, so `nix/hosts/pi.nix` turns off the GPU drivers, keeps one glibc
locale and uses the minimal git build. The installed closure is about 915 MB. The `nix-gc` user
timer deletes generations older than 7 days every week.

## Macs

1. Check the architecture with `uname -m`. The flake assumes `arm64`. For an Intel Mac, pass
   `system = "x86_64-darwin";` to that host's `mkDarwin` call.
2. Install Nix:
   ```sh
   curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
   ```
3. While `~/dotfiles` is still on the old stow branch, remove the stow symlinks, then switch
   branches:
   ```sh
   cd ~/dotfiles && stow -D . && git fetch && git switch nix
   ```
4. First switch. darwin-rebuild picks the config whose name matches `scutil --get LocalHostName`:
   ```sh
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/dotfiles
   ```
   Home Manager renames any file in its way to `*.hm-backup`.
5. Later changes:
   ```sh
   sudo darwin-rebuild switch --flake ~/dotfiles
   ```
6. Homebrew's shellenv in `~/.zprofile` puts `/opt/homebrew/bin` ahead of the Nix paths, so
   uninstall the formulae that Nix now provides:
   ```sh
   brew uninstall bat eza fzf go node nvm ripgrep zoxide zsh-autosuggestions powerlevel10k stow
   ```
   yabai and skhd are no longer used. Stop and remove them with
   `yabai --stop-service; skhd --stop-service; brew uninstall yabai skhd`.

nix-darwin installs the Homebrew taps, formulae and casks listed in a host's `homebrew` block. It
never removes ones that aren't listed (`homebrew.onActivation.cleanup = "none"`).

## Updating

```sh
cd ~/dotfiles && nix flake update && git commit -am "chore: update flake inputs"
```

Then switch on each machine. On the Pi, run `nix-collect-garbage -d` right after the switch, because
an update can download a near-complete second copy of the closure.
