# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./development.nix
      ./fonts.nix
      ./networking.nix
      ./python.nix
      ./packages.nix
      ./shell.nix
      ./sysctl.nix
      ./users-and-groups.nix
      ./virtualization.nix
      ./xserver.nix

      ./home-manager.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "LatArCyrHeb-16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;
    syncthing = {
      enable = true;
      group = "syncthing";
    };
  };

  nixpkgs.config = import ./nixpkgs-config.nix;
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
