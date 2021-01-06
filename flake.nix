{
  description = "A flake-based nixos config.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable-small";
      nixpkgs.url = "nixpkgs/master";

      nur.url = "github:nix-community/nur";
      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixos, nixpkgs, nur, home-manager, ... }:
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
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs = mkPkgs nixos [ self.overlay nur.overlay ];
      uPkgs = mkPkgs nixpkgs [ ];
    in
    {
      overlay = final: prev: {
        # This doesn't work
        # unstable = uPkgs;
        # But this one does
        unstable = inputs.nixpkgs.legacyPackages."${system}";
      };

      overlays = {
        custom = (import ./overlays/custom.nix);
        packages = (import ./overlays/packages.nix);
      };

      nixosConfigurations = {
        desktop = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./configuration.nix)
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
      };
    };
}
