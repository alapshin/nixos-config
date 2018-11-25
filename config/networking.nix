{ config, pkgs, ... }:

{
  networking.hostName = "desktop";
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
  ];
}
