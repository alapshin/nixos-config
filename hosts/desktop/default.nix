{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./ai.nix
    ./backup.nix
    ./gaming.nix
    ./networking.nix
    ./secrets.nix
    ./services.nix
    ./syncthing.nix
    ./users.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
