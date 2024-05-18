{ lib
, pkgs
, config
, ...
}: {
  imports = [
    ./domain.nix
    ./secrets.nix

    ./acme.nix
    ./audiobookshelf.nix
    ./authelia.nix
    ./calibre.nix
    ./changedetection.nix
    ./dashboard.nix
    ./grafana.nix
    ./influxdb.nix
    ./jellyfin.nix
    ./lldap.nix
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
    ./syncthing.nix
    ./wireguard.nix
    ./xray-server.nix

    ./pg-upgrade.nix

    ./networking.nix
    ./hardware-configuration.nix
  ];

  # Create media group
  users.groups.media = { };

  users.users.root.hashedPasswordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];
}
