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
    nixpkgs-lw.url = "github:NixOS/nixpkgs/pull/347353/head";
    nixpkgs-nextcloud.url = "github:NixOS/nixpkgs/pull/384565/head";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko?ref=v1.11.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-parts.follows = "flake-parts";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nvf.inputs.systems.follows = "systems";
    nvf.inputs.flake-parts.follows = "flake-parts";
    nvf.inputs.flake-utils.follows = "flake-utils";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

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
      nix-darwin,
      home-manager,
      plasma-manager,
      nvf,
      catppuccin,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (_: prev: home-manager.lib // (import ./lib { lib = prev; }));

      dotfileDir = ./dotfiles;

      pkgConfig = import ./pkgs-config.nix {
        inherit lib;
      };
      treefmtConfig = import ./treefmt-config.nix;

      mkNixpkgs =
        {
          config ? pkgConfig,
          system,
          nixpkgs,
          extraOverlays ? [ nur.overlays.default ],
        }:
        import nixpkgs {
          inherit config system;
          overlays = (lib.attrValues self.overlays) ++ extraOverlays;
        };
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = forEachSystem (system: mkNixpkgs { inherit system nixpkgs; });
      forEachSystemPkgs = function: forEachSystem (system: function eachSystemPkgs.${system});

      hmConfig = {
        home-manager = {
          # Use global pkgs configured via nixpkgs.* options
          useGlobalPkgs = true;
          # Install user packages to /etc/profiles instead.
          # Necessary for nixos-rebuild build-vm to work.
          useUserPackages = true;
          sharedModules = [
            self.homeModules.secrets
            nvf.homeManagerModules.nvf
            sops-nix.homeManagerModules.sops
            catppuccin.homeModules.catppuccin
            plasma-manager.homeManagerModules.plasma-manager
          ];
          extraSpecialArgs = {
            inherit dotfileDir;
          };
        };
      };
      mkHomeConfiguration =
        {
          hostname,
          username,
          config ? pkgConfig,
          system ? "x86_64-linux",
          userModules ? [ ],
          extraSpecialArgs ? { },
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkNixpkgs {
            inherit config system nixpkgs;
          };
          modules = userModules ++ hmConfig.home-manager.sharedModules;
          extraSpecialArgs =
            hmConfig.home-manager.extraSpecialArgs
            // {
              osConfig = {
                networking = {
                  hostName = hostname;
                };
              };
              inherit username;
            }
            // extraSpecialArgs;
        };

      mkDarwinConfiguration =
        {
          config ? pkgConfig,
          system ? "aarch64-darwin",
          hostModules ? [ ],
          sharedModules ? [
            ./configuration.nix
            sops-nix.darwinModules.sops
            home-manager.darwinModules.home-manager hmConfig
          ],
          userModules ? [ ],
          extraSpecialArgs ? { },
        }:
        let 
          pkgs = mkNixpkgs {
            inherit
              config
              system
              nixpkgs
              ;
          };
        in
        nix-darwin.lib.darwinSystem {
          inherit pkgs;
          modules = hostModules ++ sharedModules ++ userModules;
          specialArgs = {
            inherit
              self
              lib
              pkgs
              inputs
              dotfileDir
              ;
          } // extraSpecialArgs;
        };

      mkNixosConfiguration =
        {
          config ? pkgConfig,
          system ? "x86_64-linux",
          hostModules ? [ ],
          userModules ? [ ],
          sharedModules ? [
            ./configuration.nix
            nixpkgs.nixosModules.readOnlyPkgs
            self.nixosModules.backup
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager hmConfig
          ],
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          pkgs = mkNixpkgs {
            inherit
              config
              system
              nixpkgs
              ;
          };
          modules = hostModules ++ userModules ++ sharedModules;
          specialArgs = {
            inherit
              self
              lib
              inputs
              dotfileDir
              ;
          } // extraSpecialArgs;
        };
    in
    {
      devShells = forEachSystemPkgs (pkgs: {
        android =
          let
            buildToolsVersion = "36.0.0";
            androidComposition = pkgs.androidComposition;
          in
          pkgs.mkShell rec {
            buildInputs = [ androidComposition.androidsdk ];

            ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
            # Use the same buildToolsVersion here
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";

            shellHook = ''
              echo "sdk.dir=${androidComposition.androidsdk}/libexec/android-sdk" > local.properties
            '';
          };
      });

      formatter = forEachSystemPkgs (pkgs: treefmt-nix.lib.mkWrapper pkgs treefmtConfig);

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays {
        inherit inputs;
      };
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
            self.nixosModules.monica
            self.nixosModules.webhost

            "${inputs.nixpkgs-lw}/nixos/modules/services/web-apps/linkwarden.nix"
            "${inputs.nixpkgs-nextcloud}/nixos/modules/services/web-apps/nextcloud.nix"
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
          config = pkgConfig // {
            rocmSupport = true;
          };
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

      darwinConfigurations = {
        macbook = mkDarwinConfiguration {
          hostModules = [
            ./hosts/macbook
          ];
          userModules = [
            ./users/alapshin/home
          ];
          extraSpecialArgs = {
            username = "andrei.lapshin";
          };
        };
      };

      homeModules = import ./modules/home;

      # Stand-alone home-manager configuration for non NixOS machines
      homeConfigurations = {
        "alapshin@macbook" = mkHomeConfiguration {
          system = "aarch64-darwin";
          hostname = "macbook";
          username = "andrei.lapshin";
        };
      };
    };
}
