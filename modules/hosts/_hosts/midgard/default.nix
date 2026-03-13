{
  lib,
  pkgs,
  config,
  ...
}:
let
  publicIPv4 = "212.193.3.155";
in
{
  _module.args = { inherit publicIPv4; };

  imports = [
    ./openssh.nix
    ./secrets.nix
    ./caddy.nix
    ./xray-server.nix
    ./networking.nix
    ./disk-config.nix
  ];

  networking.hostName = "midgard";

  hardware.facter.reportPath = ./facter.json;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA" # laptop
    ];
  };
}
