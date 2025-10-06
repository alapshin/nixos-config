{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./backup.nix
    ./gaming.nix
    ./networking.nix
    ./secrets.nix
    ./services.nix
    ./users.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
