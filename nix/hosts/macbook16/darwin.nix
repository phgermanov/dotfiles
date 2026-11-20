# Personal MacBook system config.
{ ... }:
{
  homebrew = {
    taps = [ "felixkratz/formulae" ];
    brews = [
      "felixkratz/formulae/borders"
      "diskonaut" # not in nixpkgs
    ];
    # TODO: add the personal-only App Store apps after `mas list` confirms their IDs.
    masApps = { };
  };
}
