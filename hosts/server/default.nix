{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./secrets.nix
    ./services.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  users.users.root.passwordFile = config.sops.secrets.rootpass.path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
  ];
}
