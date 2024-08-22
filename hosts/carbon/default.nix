{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./boot.nix
    ./backup.nix
    ./secrets.nix
    ./networking.nix
    ./services.nix
    ./syncthing.nix
    ./users.nix

    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];
}
