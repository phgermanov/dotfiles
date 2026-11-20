# Shell, CLI tools and config files shared by the Pi and both Macs.
{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  # App configs stay as plain files in this repo. Home Manager symlinks them
  # straight to the checkout (like stow did), so edits apply without a rebuild
  # and apps that write their own config (lazy.nvim, Zed, Karabiner) still can.
  # The repo must be cloned at ~/dotfiles on every machine.
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
in
{
  _module.args.link = link;

  home.username = user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  xdg.enable = true;

  home.packages = with pkgs; [
    # Shell tools
    delta # lazygit pager
    eza
    fd
    jq
    lazygit
    neovim
    ripgrep

    # Default runtimes. Project pins (mise.toml) go through mise on the Macs.
    go
    nodejs
    rustup # toolchains stay in ~/.rustup
    uv # Python interpreters (uv python) and Python CLIs (uv tool)

    # Go tools. Anything nixpkgs lacks, such as counterfeiter, stays on go install.
    air
    cobra-cli
    delve
    go-tools # staticcheck
    gofumpt
    golangci-lint
    gomodifytags
    gopls
    gotests
    impl
    mockgen
    sqlc
    templ

    # Secrets
    age
    gnupg
    sops

    # Files and data. exiftool, imagemagick and yt-dlp are Mac-only (nix/home/darwin.nix).
    television
    tlrc
    wget
    yazi
    yq-go
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
    # Nix's npm can't write global packages into the store.
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Binaries that self-updating tools and language installers put in ~:
  # Claude Code, pi-bolt, uv tools, go install, cargo install, bun and npm -g.
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
    "$HOME/.npm-global/bin"
  ];

  programs.zsh = {
    enable = true;
    # Keep .zshrc and .zsh_history in ~. With xdg.enable, Home Manager 26.05
    # would otherwise move them to ~/.config/zsh.
    dotDir = config.home.homeDirectory;
    history.path = "${config.home.homeDirectory}/.zsh_history";
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    shellAliases = {
      q = "exit";
      v = "nvim";
      vic = "nvim $HOME/.config/nvim";
      ls = "eza -a --icons=always";
      cat = "bat";
      fzf = "fzf --height 40% --layout reverse --border";
    };
    initContent = ''
      typeset -U path
      export GPG_TTY="$(tty)"
      (( $+commands[pi-bolt] )) && alias pi=pi-bolt
    '';
  };

  # Prompt: Starship, Catppuccin Mocha. The config is .config/starship.toml in this repo.
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = link ".config/starship.toml";

  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--tmux bottom,40%"
      "--layout reverse"
      "--border top"
    ];
  };

  programs.zoxide.enable = true;
  programs.bat.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # No global user.name or user.email: every repo sets its own identity.
  programs.git = {
    enable = true;
    ignores = [ "**/.claude/settings.local.json" ];
  };

  # Only config.yml is managed. hosts.yml holds the login and stays writable by gh.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  # A plain package instead of programs.lazygit, whose module writes its own config.yml.
  xdg.configFile."lazygit/config.yml".source = link ".config/lazygit/config.yml";

  xdg.configFile."nvim".source = link ".config/nvim";
}
