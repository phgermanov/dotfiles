# Personal MacBook user config.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    testdisk
    zig # replaces zvm
  ];
}
