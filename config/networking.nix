{ config, pkgs, ... }:

{
  networking = {
    hostName = "desktop";
    firewall.enable = false;
    networkmanager.enable = true;
    networkmanager.packages = with pkgs; [
      networkmanager-openvpn
    ];
  };
}
