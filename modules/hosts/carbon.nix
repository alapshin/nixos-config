# carbon - Framework 13 laptop
{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostDir = ../../hosts/carbon;
in
{
  imports = [
    (hostDir + "/boot.nix")
    (hostDir + "/backup.nix")
    (hostDir + "/secrets.nix")
    (hostDir + "/networking.nix")
    (hostDir + "/services.nix")
    (hostDir + "/users.nix")
    (hostDir + "/graphical-desktop.nix")
    (hostDir + "/hardware-configuration.nix")
  ];

  networking.hostName = "carbon";
  system.stateVersion = "24.11";
}
