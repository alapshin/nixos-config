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
    nixpkgs-rocm.url = "github:NixOS/nixpkgs/pull/367695/head";
    nixpkgs-nextcloud.url = "github:NixOS/nixpkgs/pull/384565/head";

    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";
    nur.inputs.treefmt-nix.follows = "treefmt-nix";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko?ref=v1.11.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-parts.follows = "flake-parts";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    nvf.inputs.systems.follows = "systems";
    nvf.inputs.flake-parts.follows = "flake-parts";
    nvf.inputs.flake-utils.follows = "flake-utils";
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
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
      nvf,
      catppuccin,
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
          self.homeModules.secrets
          nvf.homeManagerModules.nvf
          sops-nix.homeManagerModules.sops
          catppuccin.homeModules.catppuccin
        ];
      };

      mkNixpkgs =
        {
          config ? nixpkgsConfig,
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

      mkNixosConfiguration =
        {
          config ? nixpkgsConfig,
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
        }:
        nixpkgs.lib.nixosSystem {
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = {
            inherit
              self
              lib
              inputs
              dotfileDir
              ;
            pkgs = mkNixpkgs { inherit config system nixpkgs; };
          };
        };
    in
    {
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      devShells = forEachSystemPkgs (pkgs: {
        swift = pkgs.mkShell.override { stdenv = pkgs.swift.stdenv; } {
          buildInputs = with pkgs; [
            swift
            swiftPackages.swiftpm
            swiftPackages.Dispatch
            swiftPackages.Foundation
            swiftPackages.XCTest
          ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.swiftPackages.Dispatch}/lib:$LD_LIBRARY_PATH"
          '';
        };
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
          config = nixpkgsConfig // {
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

      homeModules = import ./modules/home;

      # Stand-alone home-manager configuration for non NixOS machines
      homeConfigurations =
        let
          username = "alapshin";
        in
        {
          "${username}" = home-manager.lib.homeManagerConfiguration {
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
