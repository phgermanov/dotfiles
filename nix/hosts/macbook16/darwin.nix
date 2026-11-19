# Personal MacBook system config: AeroSpace and borders from Homebrew taps.
{ ... }:
{
  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap"
      "felixkratz/formulae"
    ];
    brews = [ "felixkratz/formulae/borders" ];
    casks = [ "nikitabobko/tap/aerospace" ];
  };
}
