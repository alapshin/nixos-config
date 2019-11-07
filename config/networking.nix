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
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  environment.systemPackages = [ pkgs.wireguard pkgs.wireguard-tools ];
}
