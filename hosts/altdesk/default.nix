{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
