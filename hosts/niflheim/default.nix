{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./domain.nix
    ./secrets.nix

    ./acme.nix
    ./ai.nix
    ./anki.nix
    ./audiobookshelf.nix
    ./authelia.nix
    ./backup.nix
    ./bitmagnet.nix
    ./calibre.nix
    ./changedetection.nix
    ./dashboard.nix
    ./grafana.nix
    ./influxdb.nix
    ./jellyfin.nix
    ./lldap.nix
    ./monica.nix
    ./navidrome.nix
    ./nginx.nix
    ./ntfy.nix
    ./nextcloud.nix
    ./openssh.nix
    ./photoprism.nix
    ./postgres.nix
    ./paperless.nix
    ./prometheus.nix
    ./transmission.nix
    ./scrutiny.nix
    ./searx.nix
    ./servarr.nix
    ./wireguard.nix

    ./pg-upgrade.nix

    ./networking.nix
    ./hardware-configuration.nix
  ];

  # Create media group
  users.groups.media = { };

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
