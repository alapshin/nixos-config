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

      nixpkgsConfig = {
          allowUnfree = true;
          firefox.enablePlasmaBrowserIntegration = true;
      };

      mkPkgs = { 
          pkgs,  
          extraOverlays ? [ nur.overlay ]
      }: import pkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = (lib.attrValues self.overlays) ++ extraOverlays;
      };
      pkgs = mkPkgs { pkgs = nixos; };

      homeManagerConfig = {
          # Use global pkgs configured via nixpkgs.* options
          home-manager.useGlobalPkgs = true;
          # Install user packages to /etc/profiles instead. 
          # Necessary for nixos-rebuild build-vm to work.
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { dotfileDir = dirs.dotfiles; };
      };
      mkNixosConfiguration = {
          system ? "x86_64-linux",
          baseModules ? [
            ./configuration.nix
            home-manager.nixosModules.home-manager homeManagerConfig
          ],
          hostModules ? [ ],
          userModules ? [ ],
      }: nixos.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = { inherit inputs pkgs self myutils; dotfileDir = dirs.dotfiles; };
      };
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
        carbon = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/carbon
          ];
          userModules = [
            ./users/alapshin
          ];
        };

        desktop = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/desktop
          ];
          userModules = [
            ./users/alapshin
          ];
        };

        altdesk = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/altdesk
          ];
          userModules = [
            ./users/alapshin
          ];
        };

        laptop = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/laptop
          ];
          userModules = [
            ./users/alapshin
          ];
        };
      };
    };
}
