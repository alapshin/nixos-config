{ lib
, pkgs
, config
, ...
}: {
  imports = [
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
