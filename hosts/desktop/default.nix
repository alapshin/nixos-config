{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./applications.nix
    ./development.nix
    ./gaming.nix
    ./networking.nix
    ./nixpkgs-utils.nix
    ./services.nix
    ./shell.nix
    ./virtualization.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
