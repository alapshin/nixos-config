{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./secrets.nix
    ./webhost.nix

    ./ai.nix
    ./anki.nix
    ./audiobookshelf.nix
    ./authelia.nix
    ./backup.nix
    ./bitmagnet.nix
    ./caddy.nix
    ./calibre.nix
    ./changedetection.nix
    ./dashboard.nix
    ./forgejo.nix
    ./freshrss.nix
    ./grafana.nix
    # ./handbrake.nix
    ./immich.nix
    ./influxdb.nix
    ./jellyfin.nix
    ./lldap.nix
    ./linkwarden.nix
    ./monica.nix
    ./ntfy.nix
    ./nextcloud.nix
    ./openssh.nix
    # ./photoprism.nix
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

  environment.systemPackages = with pkgs; [
    cuesplit
  ];

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
