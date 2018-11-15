{ config, pkgs, ... }:

{
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
  ];
}
