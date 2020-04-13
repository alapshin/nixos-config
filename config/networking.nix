{ config, pkgs, ... }:

{
  networking = {
    hostName = "desktop";
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      packages = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };
  environment.systemPackages = [ pkgs.wireguard pkgs.wireguard-tools ];
}
