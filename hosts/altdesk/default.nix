{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./bluetooth.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
