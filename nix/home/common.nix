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
    delta # lazygit pager
    eza
    fd
    go
    jq
    lazygit
    neovim
    nodejs
    ripgrep
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "$HOME/go";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/go/bin"
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
    # rustup installs outside Nix and puts cargo on PATH through this file.
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';
    initContent = ''
      typeset -U path
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
  programs.git.enable = true;

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
