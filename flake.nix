{
  description = "A flake-based NixOS config.";

  nixConfig = {
    # Will be appended to the system-level substituters
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];

    # Will be appended to the system-level trusted-public-keys
    extra-trusted-public-keys = [
      # Nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    builders-use-substitutes = true;
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    nixpkgs-lw.url = "github:jvanbruegge/nixpkgs/linkwarden";
    nixpkgs-rocm.url = "github:LunNova/nixpkgs/rocm-update";
    nixpkgs-beancount3.url = "github:alapshin/nixpkgs/beancount3";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";
    nur.inputs.treefmt-nix.follows = "treefmt-nix";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko?ref=v1.10.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=v0.4.1";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-parts.follows = "flake-parts";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      systems,
      nur,
      disko,
      sops-nix,
      lanzaboote,
      treefmt-nix,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (_: prev: home-manager.lib // (import ./lib { lib = prev; }));

      dotfileDir = ./dotfiles;

      nixpkgsConfig = import ./pkgs-config.nix {
        inherit lib;
      };
      treefmtConfig = import ./treefmt-config.nix;
      homeManagerConfig = import ./hm-config.nix {
        inherit dotfileDir;
        sharedModules = [
          sops-nix.homeManagerModules.sops
        ];
      };

      eachSystem = nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = f: eachSystem (system: f customPkgs.${system});

      mkPkgs =
        {
          system,
          nixpkgs,
          extraOverlays ? [ nur.overlays.default ],
        }:
        import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
          overlays = (lib.attrValues self.overlays) ++ extraOverlays;
        };
      customPkgs = eachSystem (system: mkPkgs { inherit nixpkgs system; });

      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          baseModules ? [
            ./configuration.nix

            nixpkgs.nixosModules.readOnlyPkgs
            self.nixosModules.backup
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ],
          hostModules ? [ ],
          userModules ? [ ],
          specialArgs ? { },
        }:
        let
          pkgs = customPkgs."${system}";
        in
        nixpkgs.lib.nixosSystem {
          # inherit system;
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = specialArgs // {
            inherit
              self
              lib
              pkgs
              inputs
              dotfileDir
              ;
          };
        };
    in
    {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      devShells = eachSystemPkgs (pkgs: {
        android =
          let
            buildToolsVersion = "35.0.0";
            androidComposition = pkgs.androidComposition;
          in
          pkgs.mkShell rec {
            buildInputs = [ androidComposition.androidsdk ];

            ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
            # Use the same buildToolsVersion here
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
          };
      });

      formatter = eachSystemPkgs (pkgs: treefmt-nix.lib.mkWrapper pkgs treefmtConfig);

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      nixosConfigurations = {
        bifrost = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/server
            ./hosts/bifrost
          ];
        };

        niflheim = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/server
            ./hosts/niflheim
            self.nixosModules.monica5
            self.nixosModules.servarr
            self.nixosModules.nginx-ext

            "${inputs.nixpkgs-lw}/nixos/modules/services/web-apps/linkwarden.nix"
          ];
        };

        carbon = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/personal
            ./hosts/carbon
          ];
          userModules = [ ./users/alapshin ];
        };

        desktop = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/personal
            ./hosts/desktop
          ];
          userModules = [ ./users/alapshin ];
        };

        altdesk = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/personal
            ./hosts/altdesk
          ];
          userModules = [ ./users/alapshin ];
        };
      };

      # Stand-alone home-manager configuration for non NixOS machines
      homeConfigurations =
        let
          username = "alapshin";
        in
        {
          "${username}" = home-manager.lib.homeManagerConfiguration {
            pkgs = customPkgs;
            modules = [ ./users/alapshin/home/home.nix ];
            extraSpecialArgs = {
              inherit username dotfileDir;
              isNixOS = false;
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
