{
  description = "A flake-based nixos config.";

  inputs = {
    nixos.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/master";

    nur.url = "github:nix-community/nur";
    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixos";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixos";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixos";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs = inputs @ {
    self,
    nixos,
    nixpkgs,
    nur,
    sops-nix,
    home-manager,
    ...
  }: let
    inherit (nixos) lib;

    system = "x86_64-linux";

    dirs = rec {
      config = builtins.toString ./.;
      dotfiles = "${config}/dotfiles";
    };
    helpers = import ./lib/helpers.nix {inherit lib;};

    nixpkgsConfig = {
      allowUnfree = true;
    };

    mkPkgs = {
      pkgs,
      extraOverlays ? [nur.overlay],
    }:
      import pkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = (lib.attrValues self.overlays) ++ extraOverlays;
      };
    pkgs = mkPkgs {pkgs = nixos;};

    homeManagerConfig = {
      # Use global pkgs configured via nixpkgs.* options
      home-manager.useGlobalPkgs = true;
      # Install user packages to /etc/profiles instead.
      # Necessary for nixos-rebuild build-vm to work.
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {dotfileDir = dirs.dotfiles;};
      home-manager.sharedModules = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ];
    };
    mkNixosConfiguration = {
      system ? "x86_64-linux",
      baseModules ? [
        ./configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager homeManagerConfig
      ],
      hostModules ? [],
      userModules ? [],
    }:
      nixos.lib.nixosSystem {
        inherit system;
        modules = baseModules ++ hostModules ++ userModules;
        specialArgs = {
          inherit inputs pkgs self;
          dotfileDir = dirs.dotfiles;
        };
      };
  in {
    overlays = {
      # If local overlay references attributes from default one
      # then its name should follow default overlay name in alphabeticall
      # order because overlays are sorted by name using `lib.attrValues`
      packages = import ./overlays/packages.nix;
      overrides = import ./overlays/overrides.nix;
      default = final: prev: {
        unstable = inputs.nixpkgs.legacyPackages.${system};
      };
    };

    devShells = {
      ${system} = {
        android = pkgs.android-fhs-env.env;
      };
    };
    formatter = {
      ${system} = pkgs.alejandra;
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
  };
}
