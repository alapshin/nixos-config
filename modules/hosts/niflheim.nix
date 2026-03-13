# niflheim - Home server hub with 40+ services
{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostDir = ../../hosts/niflheim;
in
{
  imports = [
    (hostDir + "/secrets.nix")
    (hostDir + "/webhost.nix")
    (hostDir + "/ai.nix")
    (hostDir + "/anki.nix")
    (hostDir + "/audiobookshelf.nix")
    (hostDir + "/authelia.nix")
    (hostDir + "/backup.nix")
    (hostDir + "/bitmagnet.nix")
    (hostDir + "/caddy.nix")
    (hostDir + "/changedetection.nix")
    (hostDir + "/dashboard.nix")
    (hostDir + "/docling.nix")
    (hostDir + "/freshrss.nix")
    (hostDir + "/grafana.nix")
    (hostDir + "/handbrake.nix")
    (hostDir + "/immich.nix")
    (hostDir + "/influxdb.nix")
    (hostDir + "/jellyfin.nix")
    (hostDir + "/lldap.nix")
    (hostDir + "/karakeep.nix")
    (hostDir + "/linkwarden.nix")
    (hostDir + "/monica.nix")
    (hostDir + "/nginx.nix")
    (hostDir + "/ntfy.nix")
    (hostDir + "/nextcloud.nix")
    (hostDir + "/openssh.nix")
    (hostDir + "/postgres.nix")
    (hostDir + "/paperless.nix")
    (hostDir + "/pinepods.nix")
    (hostDir + "/prometheus.nix")
    (hostDir + "/transmission.nix")
    (hostDir + "/scrutiny.nix")
    (hostDir + "/searx.nix")
    (hostDir + "/servarr.nix")
    (hostDir + "/wireguard.nix")
    (hostDir + "/xray-server.nix")
    (hostDir + "/networking.nix")
    (hostDir + "/hardware-configuration.nix")
  ];

  networking.hostName = "niflheim";
  system.stateVersion = "24.11";

  # Create media group
  users.groups.media = { };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."linux/root".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDz59Mf8DGoOjluY9T4FNFaOvXH1s/VVZ9awHcyNVHJ" # desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA" # laptop
    ];
  };
}
