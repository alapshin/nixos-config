# desktop - Main gaming/development workstation
{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostDir = ../../hosts/desktop;
in
{
  imports = [
    (hostDir + "/backup.nix")
    (hostDir + "/gaming.nix")
    (hostDir + "/networking.nix")
    (hostDir + "/secrets.nix")
    (hostDir + "/services.nix")
    (hostDir + "/users.nix")
    (hostDir + "/virtualization.nix")
    (hostDir + "/graphical-desktop.nix")
    (hostDir + "/hardware-configuration.nix")
  ];

  networking.hostName = "desktop";
  system.stateVersion = "24.11";
}
