{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./secrets.nix
    ./media.nix
    ./services.nix
    ./syncthing.nix
    ./wireguard.nix
    ./networking.nix
    ./xray-server.nix
    ./hardware-configuration.nix

    ./pg-upgrade.nix
  ];

  users.users.root.hashedPasswordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];

  environment.systemPackages = with pkgs; [
    yt-dlp
  ];
}
