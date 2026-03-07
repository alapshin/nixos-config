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
