{
  inputs,
  config,
  withSystem,
  ...
}:
{
  flake.nixosConfigurations.desktop = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-desktop
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );

  flake.nixosConfigurations.carbon = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-carbon
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );

  flake.nixosConfigurations.altdesk = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-altdesk
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );

  flake.nixosConfigurations.niflheim = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-niflheim
        "${inputs.nixpkgs-nextcloud}/nixos/modules/services/web-apps/nextcloud.nix"
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );

  flake.nixosConfigurations.bifrost = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-bifrost
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );

  flake.nixosConfigurations.midgard = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        config.flake.modules.nixos.host-midgard
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );
}
