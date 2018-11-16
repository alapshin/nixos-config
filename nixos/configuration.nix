# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ 
    ./datetime.nix
    ./development.nix
    ./fonts.nix
    ./i18n.nix
    ./misc.nix
    ./networking.nix
    ./python.nix
    ./packages.nix
    ./shell.nix
    ./sysctl.nix
    ./users-and-groups.nix
    ./virtualization.nix

    ./home-manager.nix
    ./graphical-desktop.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config = import ./nixpkgs-config.nix;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
