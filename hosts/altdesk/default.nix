{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./networking.nix
    ./graphical-desktop.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/Moscow";

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];
}
