{ config, pkgs, ... }:

{
  networking = {
    hostName = "desktop";
    networkmanager.wifi.backend = "iwd";
    interfaces = {
      "enp42s0" = {
        wakeOnLan.enable = true;
      };
    };
  };
}
