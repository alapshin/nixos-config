{
  description = "A flake-based nixos config.";

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
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";
    nur.inputs.treefmt-nix.follows = "treefmt-nix";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko?ref=v1.9.0";
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
      nur,
      disko,
      sops-nix,
      lanzaboote,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (_: prev: home-manager.lib // (import ./lib { lib = prev; }));

      system = "x86_64-linux";

      configDir = builtins.toString ./.;
      dotfileDir = "${configDir}/dotfiles";

      nixpkgsConfig = {
        android_sdk.accept_license = true;
        permittedInsecurePackages = [
          # Used by logseq
          "electron-27.3.11"
          # Used by Servarr apps
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-wrapped-6.0.428"
          "aspnetcore-runtime-6.0.36"
          "aspnetcore-runtime-wrapped-6.0.36"
        ];
        allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "drawio"
            "languagetool"

            "steam"
            "steam-original"
            "steam-run"
            "steam-unwrapped"

            "nvidia-x11"
            "nvidia-settings"

            "idea-ultimate"
            "android-studio-stable"
            "android-studio-beta"
            "android-studio-canary"
            "android-sdk-tools"
            "android-sdk-cmdline-tools"
          ];
      };

      mkPkgs =
        {
          pkgs,
          extraOverlays ? [ nur.overlays.default ],
        }:
        import pkgs {
          inherit system;
          config = nixpkgsConfig;
          overlays = (lib.attrValues self.overlays) ++ extraOverlays;
        };
      pkgs = mkPkgs { pkgs = nixpkgs; };

      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          baseModules ? [
            ./configuration.nix

            self.nixosModules.backup
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            {
              home-manager.verbose = true;
              # Use global pkgs configured via nixpkgs.* options
              home-manager.useGlobalPkgs = true;
              # Install user packages to /etc/profiles instead.
              # Necessary for nixos-rebuild build-vm to work.
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit dotfileDir;
              };
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
            }
          ],
          hostModules ? [ ],
          userModules ? [ ],
          specialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = specialArgs // {
            inherit
              inputs
              lib
              pkgs
              self
              dotfileDir
              ;
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
        };
      };

      formatter = {
        ${system} = pkgs.nixfmt-rfc-style;
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
            self.nixosModules.monica5
            self.nixosModules.servarr
            self.nixosModules.nginx-ext
            self.nixosModules.linkwarden
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
            inherit pkgs;
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
