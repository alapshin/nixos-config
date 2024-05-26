{ lib
, pkgs
, config
, ...
}: {
  imports = [
    ./secrets.nix

    ./acme.nix
    ./audiobookshelf.nix
    ./authelia.nix
    ./calibre.nix
    ./dashboard.nix
    ./jellyfin.nix
    ./lldap.nix
    ./nginx.nix
    ./nextcloud.nix
    ./openssh.nix
    ./postgres.nix
    ./paperless.nix
    ./qbittorrent.nix
    ./searx.nix
    ./servarr.nix
    # ./syncthing.nix
    ./wireguard.nix
    ./xray-server.nix
    #
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
