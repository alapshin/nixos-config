
{ config, pkgs, ... }:

{
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    lutris
    protontricks
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
  ];
}
