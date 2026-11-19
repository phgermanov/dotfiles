# Raspberry Pi home server: standalone Home Manager on Raspberry Pi OS (Debian trixie).
{ pkgs, ... }:
{
  # Sets XDG_DATA_DIRS and other paths that a non-NixOS distro doesn't.
  targets.genericLinux.enable = true;

  # Headless server: skip the Mesa GPU drivers (about 800 MB with LLVM).
  targets.genericLinux.gpu.enable = false;

  # Only the locale the Pi uses, instead of all glibc locales (220 MB).
  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_GB.UTF-8/UTF-8" ];
  };

  # Neovim without the Wayland clipboard helper, which pulls in xdg-utils and Perl.
  nixpkgs.overlays = [
    (final: prev: { neovim = prev.neovim.overrideAttrs { waylandSupport = false; }; })
  ];

  # git without Perl and Python (190 MB). It lacks send-email, svn and the man pages.
  programs.git.package = pkgs.gitMinimal;

  # Reload user units with Debian's systemctl instead of a second systemd (73 MB).
  systemd.user.systemctlPath = "/usr/bin/systemctl";

  # The root filesystem is a 29 GB SD card. A weekly user timer deletes Home
  # Manager generations older than 7 days and collects the store. It calls the
  # Nix from the installer instead of Home Manager's nix.gc, which would add a
  # second Nix to the closure. The timer runs without a login because lingering
  # is on for phgermanov.
  systemd.user.services.nix-gc = {
    Unit.Description = "Delete old Home Manager generations and collect the Nix store";
    Service = {
      Type = "oneshot";
      ExecStart = "/nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 7d";
    };
  };
  systemd.user.timers.nix-gc = {
    Unit.Description = "Weekly Nix garbage collection";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
