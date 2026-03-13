{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./backup.nix
    ./graphical-desktop.nix
    ./networking.nix
    ./secrets.nix
    ./services.nix
    ./users.nix
    ./hardware-configuration.nix
  ];

}
