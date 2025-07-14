{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
