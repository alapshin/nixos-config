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
    nixos.url = "nixpkgs/nixos-unstable-small";
    nixpkgs.url = "nixpkgs/master";

    nur.url = "github:nix-community/nur";

    disko.url = "github:nix-community/disko?ref=v1.6.1";
    disko.inputs.nixpkgs.follows = "nixos";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixos";

    lanzaboote.url = "github:nix-community/lanzaboote?ref=v0.4.1";
    lanzaboote.inputs.nixpkgs.follows = "nixos";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixos";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixos";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    inputs@{
      self,
      nixos,
      nixpkgs,
      nur,
      disko,
      sops-nix,
      lanzaboote,
      home-manager,
      ...
    }:
    let
      inherit (nixos) lib;

      system = "x86_64-linux";

      libutil = import ./util-lib { lib = nixos.lib; };
      configDir = builtins.toString ./.;
      dotfileDir = "${configDir}/dotfiles";

      nixpkgsConfig = {
        allowUnfree = true;
        android_sdk.accept_license = true;
        permittedInsecurePackages = [
          "electron-27.3.11"
          "jitsi-meet-1.0.8043"
        ];
      };

      mkPkgs =
        {
          pkgs,
          extraOverlays ? [ nur.overlay ],
        }:
        import pkgs {
          inherit system;
          config = nixpkgsConfig;
          overlays = (lib.attrValues self.overlays) ++ extraOverlays;
        };
      pkgs = mkPkgs { pkgs = nixos; };

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
        nixos.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hostModules ++ userModules;
          specialArgs = specialArgs // {
            inherit
              inputs
              pkgs
              self
              libutil
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
          android = pkgs.android-fhs-env.env;
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
            self.nixosModules.servarr
            self.nixosModules.nginx-ext
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
