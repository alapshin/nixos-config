
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steam
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
  ];
}
