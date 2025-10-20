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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/ee5dae584d759073a83cfe45195a1be807e77b74";
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

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nvf.inputs.systems.follows = "systems";
    nvf.inputs.flake-parts.follows = "flake-parts";

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
      nix-homebrew,
      home-manager,
      mac-app-util,
      plasma-manager,
      nvf,
      catppuccin,
      ...
    }:
    let
      # Extend lib with custom helper functions
      lib = nixpkgs.lib.extend (_: prev: home-manager.lib // (import ./lib { lib = prev; }));

      dotfileDir = ./dotfiles;

      pkgConfig = import ./pkgs-config.nix {
        inherit lib;
      };
      treefmtConfig = import ./treefmt-config.nix;

      mkPkgs =
        {
          config ? pkgConfig,
          system ? "x86_64-linux",
          nixpkgs ? nixpkgs,
        }:
        import nixpkgs {
          inherit config system;
          overlays = (lib.attrValues self.overlays) ++ [ nur.overlays.default ];
        };
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      eachSystemPkgs = forEachSystem (system: mkPkgs { inherit system nixpkgs; });
      forEachSystemPkgs = function: forEachSystem (system: function eachSystemPkgs.${system});

      homeConfig = {
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
            mac-app-util.homeManagerModules.default
            plasma-manager.homeModules.plasma-manager
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
          nixpkgs ? inputs.nixpkgs,
          homeModules,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs {
            inherit config system nixpkgs;
          };
          modules = homeConfig.home-manager.sharedModules ++ homeModules;
          extraSpecialArgs = homeConfig.home-manager.extraSpecialArgs // {
            inherit username;
            osConfig = {
              networking = {
                hostName = hostname;
              };
            };
          };
        };
      mkDarwinConfiguration =
        {
          config ? pkgConfig,
          system ? "aarch64-darwin",
          hostModules ? [ ],
          userModules ? [ ],
        }:
        let
          pkgs = mkPkgs {
            inherit config system nixpkgs;
          };
          sharedModules = [
            ./configuration.nix
            inputs.determinate.darwinModules.default
            sops-nix.darwinModules.sops
            mac-app-util.darwinModules.default
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager homeConfig
          ];
        in
        nix-darwin.lib.darwinSystem {
          inherit pkgs;
          modules = sharedModules ++ hostModules ++ userModules;
          specialArgs = {
            inherit
              self
              lib
              pkgs
              inputs
              dotfileDir
              ;
          };
        };

      mkNixosConfiguration =
        {
          config ? pkgConfig,
          system ? "x86_64-linux",
          nixpkgs ? inputs.nixpkgs,
          hostModules ? [ ],
          userModules ? [ ],
        }:
        let
          sharedModules = [
            ./configuration.nix
            nixpkgs.nixosModules.readOnlyPkgs
            self.nixosModules.backup
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager homeConfig
          ];
        in
        nixpkgs.lib.nixosSystem {
          pkgs = mkPkgs {
            inherit config system nixpkgs;
          };
          modules = sharedModules ++ hostModules ++ userModules;
          specialArgs = {
            inherit
              self
              lib
              inputs
              dotfileDir
              ;
          };
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
          nixpkgs = inputs.nixpkgs;
          hostModules = [
            ./hosts/common
            ./hosts/server
            ./hosts/niflheim
            self.nixosModules.monica
            self.nixosModules.webhost

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
            rocmSupport = false;
          };
          hostModules = [
            ./hosts/common
            ./hosts/personal
            ./hosts/desktop
          ];
          userModules = [
            ./users/alapshin
            ./users/alapshin/home
          ];
        };

        altdesk = mkNixosConfiguration {
          hostModules = [
            ./hosts/common
            ./hosts/personal
            ./hosts/altdesk
          ];
          userModules = [
            ./users/alapshin
            ./users/alapshin/home
          ];
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
        };
      };

      homeModules = import ./modules/home;

      homeConfigurations = {
        "alapshin@macbook" = mkHomeConfiguration {
          system = "aarch64-darwin";
          hostname = "macbook";
          username = "andrei.lapshin";
          homeModules = [
            ./users/alapshin/home/home.nix
          ];
        };
        "alapshin@desktop" = mkHomeConfiguration {
          system = "x86_64-linux";
          hostname = "desktop";
          username = "alapshin";
          homeModules = [
            ./users/alapshin/home/home.nix
          ];
        };
      };
    };
}
