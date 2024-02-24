{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./acme.nix
    ./authelia.nix
    ./borg.nix
    ./lldap.nix
    ./media.nix
    ./nextcloud.nix
    ./openssh.nix
    ./postgres.nix
    ./secrets.nix
    ./services.nix
    ./syncthing.nix
    ./wireguard.nix
    ./xray-server.nix

    ./pg-upgrade.nix

    ./networking.nix
    ./hardware-configuration.nix
  ];

  users.users.root.hashedPasswordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];

  environment.systemPackages = with pkgs; [
    yt-dlp
  ];
}
