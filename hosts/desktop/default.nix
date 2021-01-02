{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./gaming.nix
    ./networking.nix
    ./services.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
