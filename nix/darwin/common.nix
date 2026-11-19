# macOS system config shared by both Macs.
{ user, ... }:
{
  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  # Assumes the upstream multi-user Nix installer. With Determinate Nix, set
  # nix.enable = false and drop the nix.* options below.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      user
    ];
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Writes /etc/zshrc so login shells get the Nix paths.
  programs.zsh.enable = true;

  # Homebrew stays for anything not in nixpkgs. nix-darwin only touches it on a
  # host that sets homebrew.enable, and cleanup = "none" leaves unlisted
  # formulae and casks installed.
  homebrew.onActivation.cleanup = "none";

  system.stateVersion = 6;
}
