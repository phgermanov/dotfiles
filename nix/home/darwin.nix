# User config shared by both Macs.
{
  lib,
  pkgs,
  link,
  ...
}:
{
  home.packages = with pkgs; [ tmux ];

  home.sessionPath = [ "$HOME/.local/scripts" ];

  programs.zsh = {
    shellAliases.work = "cd $HOME/Work";
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"
    '';
  };

  home.file.".local/scripts".source = link ".local/scripts";

  xdg.configFile = lib.genAttrs [
    "aerospace"
    "alacritty"
    "ghostty"
    "kitty"
    "neovide"
    "tmux"
    "zed"
  ] (name: { source = link ".config/${name}"; });
}
