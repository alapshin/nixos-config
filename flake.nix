{
  description = "A flake-based nixos config.";

  inputs = {
    nixos.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/master";

    nur.url = "github:nix-community/nur";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixos";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixos";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixos";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixos";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixos";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    inputs @ { self
    , nixos
    , nixpkgs
    , nur
    , disko
    , sops-nix
    , lanzaboote
    , home-manager
    , ...
    }:
    let
      inherit (nixos) lib;

      system = "x86_64-linux";

      configDir = builtins.toString ./.;
      dotfileDir = "${configDir}/dotfiles";

      nixpkgsConfig = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      mkPkgs =
        { pkgs
        , extraOverlays ? [ nur.overlay ]
        }:
        import pkgs {
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
        home-manager.extraSpecialArgs = {
          inherit dotfileDir;
        };
        home-manager.sharedModules = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
      };
      mkNixosConfiguration =
        { system ? "x86_64-linux"
        , baseModules ? [
            ./configuration.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ]
        , hostModules ? [ ]
        , userModules ? [ ]
        ,
        }:
        nixos.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = {
            inherit inputs pkgs self dotfileDir;
          };
        };
    in
    {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages acessible through 'nix build', 'nix shell', etc
      # packages = import ./packages {inherit pkgs;};

      devShells = {
        ${system} = {
          android = pkgs.android-fhs-env.env;
        };
      };
      formatter = {
        ${system} = pkgs.nixpkgs-fmt;
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
      };
      # Stand-alone home-manager configuration for non NixOS machines
      homeConfigurations =
        let
          username = "alapshin";
        in
        {
          "${username}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./users/alapshin/home/home.nix ];
            extraSpecialArgs = {
              inherit username dotfileDir;
              osConfig = {
                networking = {
                  hostName = "workstation";
                };
              };
            };
          };
        };
    };
}
