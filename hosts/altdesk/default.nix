{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./backup.nix
    ./bluetooth.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
