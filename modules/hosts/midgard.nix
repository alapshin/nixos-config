# midgard - Vultr VPS, web server with caddy and secondary VPN relay
{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostDir = ../../hosts/midgard;
  publicIPv4 = "212.193.3.155";
in
{
  _module.args = { inherit publicIPv4; };

  imports = [
    (hostDir + "/openssh.nix")
    (hostDir + "/secrets.nix")
    (hostDir + "/caddy.nix")
    (hostDir + "/xray-server.nix")
    (hostDir + "/networking.nix")
    (hostDir + "/disk-config.nix")
  ];

  networking.hostName = "midgard";
  system.stateVersion = "24.11";

  hardware.facter.reportPath = hostDir + "/facter.json";

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA" # laptop
    ];
  };
}
