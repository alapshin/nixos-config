{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./openssh.nix
    ./secrets.nix
    ./xray-server.nix

    ./networking.nix
    ./disk-config.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ"
      # laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
    ];
  };
}
