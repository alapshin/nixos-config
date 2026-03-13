{ ... }:
{
  flake.homeModules = import ./_home-modules;
  flake.nixosModules = import ./_nixos-modules;
}
