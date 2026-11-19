{
  description = "phgermanov's machines: Raspberry Pi home server and MacBooks";

  inputs = {
    # Linux hosts follow the NixOS release channel, Macs the darwin channel of the same release.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      # One nix-darwin system per Mac. Home Manager runs inside it, so
      # `darwin-rebuild switch` applies both the system and the user config.
      # Exported as lib.mkDarwin so a private flake can build a Mac from these
      # modules without putting that Mac's details in this public repo.
      mkDarwin =
        {
          user,
          system ? "aarch64-darwin",
          darwinModules ? [ ],
          homeModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user; };
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./nix/darwin/common.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Files that already exist, such as stow symlinks, get renamed to *.hm-backup.
                backupFileExtension = "hm-backup";
                extraSpecialArgs = { inherit user; };
                users.${user}.imports = [
                  ./nix/home/common.nix
                  ./nix/home/darwin.nix
                ]
                ++ homeModules;
              };
            }
          ]
          ++ darwinModules;
        };
    in
    {
      lib = { inherit mkDarwin; };

      # Raspberry Pi 5, Debian trixie. Standalone Home Manager, the OS stays Raspberry Pi OS.
      homeConfigurations."phgermanov@pi" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs.user = "phgermanov";
        modules = [
          ./nix/home/common.nix
          ./nix/hosts/pi.nix
        ];
      };

      # Personal MacBook. The attribute name is its LocalHostName.
      darwinConfigurations.macbook16 = mkDarwin {
        user = "phgermanov";
        darwinModules = [ ./nix/hosts/macbook16/darwin.nix ];
        homeModules = [ ./nix/hosts/macbook16/home.nix ];
      };
    };
}
