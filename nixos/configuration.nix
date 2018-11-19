{ config, options, pkgs, ... }:

{
  imports = [ 
    ./datetime.nix
    ./development.nix
    ./fonts.nix
    ./gaming.nix
    ./i18n.nix
    ./misc.nix
    ./networking.nix
    ./python.nix
    ./packages.nix
    ./security.nix
    ./shell.nix
    ./sysctl.nix
    ./users-and-groups.nix
    ./virtualization.nix

    ./home-manager.nix
    ./graphical-desktop.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Make overlays available to commmand-line tools. 
  nix.nixPath = options.nix.nixPath.default 
    ++ [ "nixpkgs-overlays=/etc/nixos/overlays/" ];
  nixpkgs.config = import ./nixpkgs-config.nix;
  nixpkgs.overlays = [ 
    (import ./overlays/custom.nix)
    (import ./overlays/unstable.nix)
  ];
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
