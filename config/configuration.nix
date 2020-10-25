{ config, lib, options, pkgs, ... }:

{
  imports = [ 
    ./audio.nix
    ./applications.nix
    ./common.nix
    ./development.nix
    ./gaming.nix
    ./networking.nix
    ./nixpkgs-utils.nix
    ./services.nix
    ./shell.nix
    ./users-and-groups.nix
    ./virtualization.nix

    ./home-manager.nix
    ./graphical-desktop.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  nix.maxJobs = lib.mkDefault 4;
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command
  '';
  # Make overlays available to commmand-line tools. 
  nix.nixPath = options.nix.nixPath.default 
    ++ [ "nixpkgs-overlays=/etc/nixos/overlays/" ];
  nixpkgs.config = import ./nixpkgs-config.nix;
  nixpkgs.overlays = let dir = ./overlays; in 
    map (f: import (dir + "/${f}")) (builtins.attrNames (builtins.readDir dir));

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
