# altdesk - Alternate desktop workstation
{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostDir = ../../hosts/altdesk;
in
{
  imports = [
    (hostDir + "/networking.nix")
    (hostDir + "/graphical-desktop.nix")
    (hostDir + "/hardware-configuration.nix")
  ];

  networking.hostName = "altdesk";
  system.stateVersion = "24.11";

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];
}
