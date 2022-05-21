{
  description = "A flake-based nixos config.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-21.11-small";
      nixpkgs.url = "nixpkgs/master";

      nur.url = "github:nix-community/nur";
      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixos";
      };
    };

  outputs = inputs @ { self, nixos, nixpkgs, stable, nur, home-manager, ... }:
    let
      inherit (nixos) lib;

      system = "x86_64-linux";

      dirs = rec {
        config = builtins.toString ./.;
        users = "${config}/users";
        dotfiles = "${config}/dotfiles";
      };
      myutils = import ./lib/utils.nix { inherit lib dirs; };

      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config = {
          allowUnfree = true;
          firefox.enablePlasmaBrowserIntegration = true;
        };
        overlays = (lib.attrValues self.overlays) ++ extraOverlays;
      };

      pkgs = mkPkgs nixos [ nur.overlay ];
    in
    {
      overlays = {
        # If local overlay references attributes from default one 
        # then its name should follow default overlay name in alphabeticall 
        # order because overlays are sorted by name using `lib.attrValues`
        packages = (import ./overlays/packages.nix);
        overrides = (import ./overlays/overrides.nix);
        default = final: prev: {
            stable = inputs.stable.legacyPackages."${system}";
            unstable = inputs.nixpkgs.legacyPackages."${system}";
        };
      };

      devShells = {
          "${system}" = {
              android = pkgs.android-fhs-env.env;
          };
      };

      nixosConfigurations = {
        carbon = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix)
            (import ./hosts/common)
            (import ./hosts/carbon)
            (import ./users/alapshin)
            home-manager.nixosModules.home-manager
            {
              # Use global pkgs configured via nixpkgs.* options
              home-manager.useGlobalPkgs = true;
              # Install user packages to /etc/profiles instead. 
              # Necessary for nixos-rebuild build-vm to work.
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs pkgs self dirs myutils; };
        };

        desktop = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix)
            (import ./hosts/common)
            (import ./hosts/desktop)
            (import ./users/alapshin)
            home-manager.nixosModules.home-manager
            {
              # Use global pkgs configured via nixpkgs.* options
              home-manager.useGlobalPkgs = true;
              # Install user packages to /etc/profiles instead. 
              # Necessary for nixos-rebuild build-vm to work.
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs pkgs self dirs myutils; };
        };

        altdesk = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix)
            (import ./hosts/common)
            (import ./hosts/altdesk)
            (import ./users/alapshin)
            home-manager.nixosModules.home-manager
            {
              # Use global pkgs configured via nixpkgs.* options
              home-manager.useGlobalPkgs = true;
              # Install user packages to /etc/profiles instead. 
              # Necessary for nixos-rebuild build-vm to work.
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs pkgs self dirs myutils; };
        };


        laptop = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix)
            (import ./hosts/common)
            (import ./hosts/laptop)
            (import ./users/alapshin)
            home-manager.nixosModules.home-manager
            {
              # Use global pkgs configured via nixpkgs.* options
              home-manager.useGlobalPkgs = true;
              # Install user packages to /etc/profiles instead. 
              # Necessary for nixos-rebuild build-vm to work.
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs pkgs self dirs myutils; };
        };
      };
    };
}
