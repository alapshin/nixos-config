# Dendritic module structure using flake-parts
{
  inputs,
  ...
}:
{
  # Import core module definitions from separate files
  imports = [
    ./lib.nix
    ./pkgs.nix
    ./overlays.nix
    ./formatter.nix
    ./dev-shells.nix
    ./configurations.nix
    ./exported-modules.nix
  ];

  # Core flake outputs configuration
  systems = import inputs.systems;
}
