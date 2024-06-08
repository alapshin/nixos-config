{ lib
, pkgs
, config
, ...
}: {
  imports = [
    ./openssh.nix
    ./secrets.nix
    ./xray-server.nix

    ./networking.nix
    ./hardware-configuration.nix
  ];

  users.users.root.hashedPasswordFile = config.sops.secrets."linux/root".path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];
}
