# User config shared by every Mac.
{
  config,
  lib,
  pkgs,
  link,
  ...
}:
let
  # tpm, the tmux plugin manager. It installs the other plugins from tmux.conf
  # into ~/.tmux/plugins on the first prefix + I.
  tpm = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
    hash = "sha256-hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
  };
in
{
  home.packages = with pkgs; [
    tmux

    # Containers and Kubernetes. Colima is the only Docker runtime.
    colima
    docker-client
    k9s
    kubectl
    kubernetes-helm
    qemu # colima VMs use vmType qemu

    pinentry_mac # gpg passphrase prompts

    # Media tools, kept off the Pi's SD card (yt-dlp alone is 650 MB).
    exiftool
    imagemagick
    yt-dlp
  ];

  # Per-project runtime versions from mise.toml, .tool-versions and .nvmrc.
  # Mac-only: its closure is 520 MB and the Pi has no mise projects.
  programs.mise.enable = true;

  home.sessionPath = [ "$HOME/.local/scripts" ];

  # Home server endpoints: Caddy's internal CA and the SearXNG JSON API.
  home.sessionVariables = {
    NODE_EXTRA_CA_CERTS = "${config.home.homeDirectory}/.certs/home-ca.pem";
    SEARXNG_URL = "https://search.home.arpa";
  };

  programs.zsh = {
    shellAliases = {
      k = "kubectl";
      work = "cd $HOME/Work";
    };
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"
      source <(kubectl completion zsh)
    '';
  };

  home.file.".local/scripts".source = link ".local/scripts";
  home.file.".tmux/plugins/tpm".source = tpm;

  xdg.configFile = {
    "aerospace".source = link ".config/aerospace";
    "ghostty".source = link ".config/ghostty";
    "neovide".source = link ".config/neovide";
    "tmux/tmux.conf".source = link ".config/tmux/tmux.conf";
    # Files, not the folder: Zed writes conversations/ and prompts/ next to them.
    "zed/settings.json".source = link ".config/zed/settings.json";
    "zed/keymap.json".source = link ".config/zed/keymap.json";
    "zed/tasks.json".source = link ".config/zed/tasks.json";
  };

  # Public hosts only. A Mac's keys, users and private hosts go in
  # ~/.ssh/config.local, which is read first, so its values win. Keys never
  # enter the Nix store.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "~/.ssh/config.local"
      "~/.colima/ssh_config"
      "~/.config/colima/ssh_config"
    ];
    settings = {
      pi = {
        HostName = "pi.local";
        User = "phgermanov";
      };
      pi-ts = {
        HostName = "pi.tail0e4878.ts.net";
        User = "phgermanov";
      };
      "phgermanov.com hetzner dokku" = {
        HostName = "phgermanov.com";
      };
      "phgermanov.com-admin" = {
        HostName = "159.69.194.76";
      };
      "*" = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
    };
  };
}
