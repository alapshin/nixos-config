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
    ./gaming.nix
    ./networking.nix
    ./services.nix
    ./syncthing.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];

  time = {
    timeZone = pkgs.lib.mkForce "Europe/Belgrade";
  };
}
