{ config, pkgs, ... }:

{
  networking = {
    hostName = "laptop";
    networkmanager.wifi.backend = "iwd";
  };
}
