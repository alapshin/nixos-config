{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
