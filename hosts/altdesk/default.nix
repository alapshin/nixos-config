{ config, lib, pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
