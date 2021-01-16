{ config, pkgs, ... }:

{
  networking = {
    hostName = "desktop";
    networkmanager.wifi.backend = "iwd";
  };
}
