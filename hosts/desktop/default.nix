{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./gaming.nix
    ./networking.nix
    ./services.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
