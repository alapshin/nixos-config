{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./backup.nix
    ./secrets.nix
    ./bluetooth.nix
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
