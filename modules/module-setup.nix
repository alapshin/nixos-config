# Infrastructure modules needed by all NixOS hosts
{ inputs, ... }:
{
  flake.modules.nixos.infra =
    { ... }:
    {
      imports = [
        inputs.self.modules.generic.dotfiles
        inputs.nixpkgs.nixosModules.readOnlyPkgs
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          inputs.self.modules.generic.dotfiles
          inputs.self.modules.homeManager.infra
          inputs.self.modules.homeManager.secrets
        ];
      };
    };
  flake.modules.homeManager.infra = {
    imports = [
      inputs.nvf.homeManagerModules.nvf
      inputs.sops-nix.homeManagerModules.sops
      inputs.catppuccin.homeModules.catppuccin
      inputs.plasma-manager.homeModules.plasma-manager
    ];
  };
}
