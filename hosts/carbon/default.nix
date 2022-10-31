{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./bluetooth.nix
    ./networking.nix
    ./services.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];

  time = {
    timeZone = pkgs.lib.mkForce "Europe/Podgorica";
  };
}
