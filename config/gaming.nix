
{ config, pkgs, ... }:

{
  hardware.steam-hardware.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
  '';
  environment.systemPackages = with pkgs; [
    lutris
    steam
    steam-run
    sc-controller
    protontricks
    wineWowPackages.staging
    (winetricks.override { wine = wineWowPackages.staging; })
  ];
}
