# Flake outputs for nixosConfigurations and homeConfigurations
{
  self,
  inputs,
  withSystem,
  lib,
  ...
}:
let
  dotfileDir = ../dotfiles;

  # Shared modules applied to all NixOS configurations
  sharedNixosModules = [
    ../configuration.nix
    inputs.nixpkgs.nixosModules.readOnlyPkgs
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.home-manager.nixosModules.home-manager
    # Custom nixos modules that define options used by old host configs
    self.nixosModules.backup
  ];

  # Shared home-manager config
  sharedHomeConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        self.homeModules.secrets
        inputs.nvf.homeManagerModules.nvf
        inputs.sops-nix.homeManagerModules.sops
        inputs.catppuccin.homeModules.catppuccin
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      extraSpecialArgs = {
        inherit inputs;
        inherit dotfileDir;
      };
    };
  };

  # Helper function to create a NixOS configuration
  mkNixosHost =
    {
      system ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      hostModules ? [ ],
      userModules ? [ ],
      extraPkgsConfig ? { },
    }:
    withSystem system (
      { pkgs, ... }:
      nixpkgs.lib.nixosSystem {
        pkgs =
          if extraPkgsConfig == { } then
            pkgs
          else
            import nixpkgs {
              inherit system;
              config = (import ../pkgs-config.nix { lib = inputs.nixpkgs.lib; }) // extraPkgsConfig;
              overlays = (builtins.attrValues self.overlays) ++ [ inputs.nur.overlays.default ];
            };
        modules = sharedNixosModules ++ [ sharedHomeConfig ] ++ hostModules ++ userModules;
        specialArgs = {
          inherit self inputs dotfileDir;
          lib = inputs.nixpkgs.lib.extend (
            _: prev: inputs.home-manager.lib // (import ../lib { lib = prev; })
          );
        };
      }
    );

  # Helper function for standalone home-manager configurations
  mkHome =
    {
      system,
      hostname,
      username,
      homeModules,
    }:
    withSystem system (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeModules.secrets
          inputs.nvf.homeManagerModules.nvf
          inputs.sops-nix.homeManagerModules.sops
          inputs.catppuccin.homeModules.catppuccin
          inputs.plasma-manager.homeModules.plasma-manager
        ]
        ++ homeModules;
        extraSpecialArgs = {
          inherit inputs username;
          inherit dotfileDir;
          osConfig = {
            networking.hostName = hostname;
          };
        };
      }
    );

in
{
  flake.nixosConfigurations = {
    bifrost = mkNixosHost {
      hostModules = [
        ../hosts/common
        ../hosts/server
        ./hosts/bifrost.nix
      ];
    };

    midgard = mkNixosHost {
      hostModules = [
        ../hosts/common
        ../hosts/server
        ./hosts/midgard.nix
      ];
    };

    niflheim = mkNixosHost {
      hostModules = [
        ../hosts/common
        ../hosts/server
        ./hosts/niflheim.nix
        self.nixosModules.vpn
        self.nixosModules.monica
        self.nixosModules.webhost
        "${inputs.nixpkgs-nextcloud}/nixos/modules/services/web-apps/nextcloud.nix"
      ];
    };

    carbon = mkNixosHost {
      hostModules = [
        ../hosts/common
        ../hosts/personal
        ./hosts/carbon.nix
      ];
      userModules = [
        ./users/alapshin.nix
      ];
    };

    desktop = mkNixosHost {
      extraPkgsConfig = {
        rocmSupport = false;
      };
      hostModules = [
        ../hosts/common
        ../hosts/personal
        ./hosts/desktop.nix
      ];
      userModules = [
        ./users/alapshin.nix
      ];
    };

    altdesk = mkNixosHost {
      hostModules = [
        ../hosts/common
        ../hosts/personal
        ./hosts/altdesk.nix
      ];
      userModules = [
        ./users/alapshin.nix
      ];
    };
  };

  flake.darwinConfigurations.macbook = withSystem "aarch64-darwin" (
    { pkgs, ... }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit pkgs;
      modules = [
        ../configuration.nix
        inputs.determinate.darwinModules.default
        inputs.sops-nix.darwinModules.sops
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.home-manager.darwinModules.home-manager
        sharedHomeConfig
        ./hosts/macbook.nix
        ../users/alapshin/home/home.nix
      ];
      specialArgs = {
        inherit self inputs;
        lib = inputs.nixpkgs.lib.extend (
          _: prev: inputs.home-manager.lib // (import ../lib { lib = prev; })
        );
        inherit dotfileDir;
      };
    }
  );

  flake.homeConfigurations = {
    "alapshin@desktop" = mkHome {
      system = "x86_64-linux";
      hostname = "desktop";
      username = "alapshin";
      homeModules = [ ../users/alapshin/home/home.nix ];
    };

    "alapshin@macbook" = mkHome {
      system = "aarch64-darwin";
      hostname = "macbook";
      username = "andrei.lapshin";
      homeModules = [ ../users/alapshin/home/home.nix ];
    };
  };
}
