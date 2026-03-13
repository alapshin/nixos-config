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
    ./hardware-configuration.nix
  ];

  networking.hostName = "bifrost";

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA" # laptop
    ];
  };
}
