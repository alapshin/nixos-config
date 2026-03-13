# bifrost - Linode VPS, VPN relay server
{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Anchored paths to host-specific files (they stay in hosts/bifrost/)
  hostDir = ../../hosts/bifrost;
in
{
  imports = [
    (hostDir + "/openssh.nix")
    (hostDir + "/secrets.nix")
    (hostDir + "/xray-server.nix")
    (hostDir + "/networking.nix")
    (hostDir + "/hardware-configuration.nix")
  ];

  networking.hostName = "bifrost";
  system.stateVersion = "24.11";

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA" # laptop
    ];
  };
}
