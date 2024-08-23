{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./backup.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
    ./syncthing.nix
  ];
}
