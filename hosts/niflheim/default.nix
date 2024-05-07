{ lib
, pkgs
, config
, ...
}: {
  imports = [
    ./acme.nix
    ./audiobookshelf.nix
    ./authelia.nix
    # ./calibre.nix
    # ./dashboard.nix
    ./lldap.nix
    ./media.nix
    ./nginx.nix
    ./nextcloud.nix
    ./openssh.nix
    ./postgres.nix
    # ./paperless.nix
    # ./qbittorrent.nix
    ./secrets.nix
    # ./syncthing.nix
    # ./wireguard.nix
    # ./xray-server.nix
    #
    ./pg-upgrade.nix
    #
    ./networking.nix
    ./hardware-configuration.nix
  ];

  users.users.root.hashedPasswordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];
}
