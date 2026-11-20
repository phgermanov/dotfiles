# Dotfiles

A Nix flake that configures the Raspberry Pi home server and a MacBook:

| Config | Machine | Tool |
|---|---|---|
| `phgermanov@pi` | Raspberry Pi 5 home server, Raspberry Pi OS | Home Manager, standalone |
| `macbook16` | MacBook | nix-darwin with Home Manager |

Every machine gets the same zsh setup (oh-my-zsh git plugin, autosuggestions, Starship, fzf,
zoxide, direnv) and the same CLI tools: go, node, rustup, uv, the common Go tools, sops, age and
gnupg. Home Manager generates `~/.zshrc`. No machine sets a global git identity, so every repo
sets its own `user.name` and `user.email`.

Language runtimes:

| Language | Default | Per project |
|---|---|---|
| Go, Node | Nix | mise on the Macs (`mise.toml`, `.tool-versions`, `.nvmrc`) |
| Rust | rustup from Nix, toolchains in `~/.rustup` | `rust-toolchain.toml` |
| Python | none | `uv python install`, `uv tool install` for CLIs |

Self-updating tools stay outside Nix: Claude Code, pi-bolt, bun and npm globals. The flake only
puts `~/.local/bin`, `~/.bun/bin`, `~/.npm-global/bin`, `~/go/bin` and `~/.cargo/bin` on PATH.

App configs stay as plain files under `.config/`. Home Manager symlinks them to this checkout, so
edits apply without a rebuild. The repo must be cloned at `~/dotfiles`.

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, Home Manager, nix-darwin), the machine configs and `lib.mkDarwin` |
| `nix/home/common.nix` | Shell, CLI tools and config links for every machine |
| `nix/home/darwin.nix` | Every Mac: colima, kubectl, k9s, helm, mise, media tools, SSH hosts, app config links |
| `nix/darwin/common.nix` | Every Mac: Homebrew casks, App Store apps, fonts, Caps Lock to Control, macOS preferences |
| `nix/hosts/pi.nix` | Pi only: disk-saving overrides and a weekly garbage-collection timer |
| `nix/hosts/macbook16/` | `macbook16` only: borders, diskonaut, testdisk, zig |

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
locale and uses the minimal git build. mise, yt-dlp, imagemagick and exiftool are Mac-only for the
same reason. The installed closure is about 1.7 GB. The `nix-gc` user timer deletes generations
older than 7 days every week.

## Macs

1. Install Nix:
   ```sh
   curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
   ```
2. Move the old hand-written configs aside:
   ```sh
   mv ~/.ssh/config ~/.ssh/config.local   # then delete the blocks nix/home/darwin.nix declares
   mv ~/.gitconfig ~/.gitconfig.pre-nix   # identities go per repo, tokens go to `gh auth login`
   ```
   `~/.ssh/config.local` keeps this Mac's `User` and `IdentityFile` lines. It is read first, so
   its values win.
3. While `~/dotfiles` is still on the old stow branch, remove the stow symlinks, then switch
   branches:
   ```sh
   cd ~/dotfiles && stow -D . && git fetch && git switch nix
   ```
4. Sign in to the App Store, then run the first switch. darwin-rebuild picks the config whose name
   matches `scutil --get LocalHostName`:
   ```sh
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/dotfiles
   ```
   Home Manager renames any file in its way to `*.hm-backup`. Homebrew refuses to install a cask
   over an app it didn't install; adopt those once with `brew install --cask --adopt <name>`.
5. Later changes:
   ```sh
   sudo darwin-rebuild switch --flake ~/dotfiles
   ```
6. In tmux, press prefix + I once. tpm then installs the plugins to `~/.tmux/plugins`.

nix-darwin installs the Homebrew taps, formulae and casks listed in the config. It never removes
ones that aren't listed (`homebrew.onActivation.cleanup = "none"`), so remove the old ones by hand.

### Remove from macbook16 after the switch

Replaced by Nix:

```sh
brew uninstall bat direnv eza fzf gh git git-delta go lazygit neovim node ripgrep starship tmux \
  zoxide zsh-autosuggestions nvm stow powerlevel10k colima qemu docker k9s kubernetes-cli \
  pnpm sops wget yq yt-dlp exiftool golang-migrate protobuf rust \
  python@3.9 python@3.10 python@3.11 python@3.13 gobject-introspection guile
rm -rf ~/.oh-my-zsh ~/.p10k.zsh ~/.zvm ~/.config/nvm ~/.nvm ~/.local/bin/uv ~/.local/bin/uvx
```

Dropped:

```sh
yabai --stop-service; skhd --stop-service
brew uninstall yabai skhd minikube terraform nats nats-server atlas ipatool scrcpy zellij \
  cmake putty unbound tabby encore mole
brew uninstall --cask fig kitty wezterm alacritty karabiner-elements android-platform-tools \
  font-mononoki-nerd-font
brew untap asmvik/formulae koekeishiya/formulae hashicorp/tap nats-io/nats-tools tabbyml/tabby \
  encoredev/tap jandedobbeleer/oh-my-posh homebrew/bundle homebrew/cask-fonts
rm ~/Library/LaunchAgents/io.fig.*.plist ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
```

Also by hand:
- Remove the python.org Python 3.10 framework and its `/usr/local/bin` links.
- Remove the broken `/usr/local/bin` links, and the `co.elastic.elastic-agent` LaunchDaemon,
  whose binary is gone.
- Uninstall Docker Desktop, Rancher Desktop, Warp and iTerm2, then remove `~/.rd`.
- Remove the unused fonts from `~/Library/Fonts`: Iosevka, JetBrains Mono and MesloLGS.

## Updating

```sh
cd ~/dotfiles && nix flake update && git commit -am "chore: update flake inputs"
```

Then switch on each machine. On the Pi, run `nix-collect-garbage -d` right after the switch, because
an update can download a near-complete second copy of the closure.
