{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./secrets.nix
    ./xray.nix
    ./media.nix
    ./services.nix
    ./wireguard.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  users.users.root.passwordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];
}
