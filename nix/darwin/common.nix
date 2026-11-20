# macOS system config shared by every Mac.
{ pkgs, user, ... }:
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

  # GUI apps and anything nixpkgs lacks. cleanup = "none" leaves formulae and
  # casks that aren't listed here installed; uninstall those by hand.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    taps = [ "nikitabobko/tap" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
      "jordanbaird-ice"

      "neovide-app"
      "visual-studio-code"
      "zed"

      "firefox"
      "google-chrome"
      "zen"

      "alt-tab"
      "betterdisplay"
      "iina"
      "keka"
      "lunar"
      "monitorcontrol"
      "raycast"
      "stats"
    ];
    # Needs a signed-in App Store account. Find IDs with `mas list`.
    masApps = {
      Amphetamine = 937984704;
      Bitwarden = 1352778147;
    };
  };

  fonts.packages = with pkgs; [
    mononoki
    nerd-fonts.mononoki
    nerd-fonts.fira-code
  ];

  # Caps Lock is Control on every keyboard. This replaces Karabiner.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
      wvous-br-corner = 14; # Quick Note
    };
    finder = {
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    trackpad = {
      Clicking = false; # no tap to click
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };
    WindowManager.GloballyEnabled = false; # Stage Manager off
  };

  system.stateVersion = 6;
}
