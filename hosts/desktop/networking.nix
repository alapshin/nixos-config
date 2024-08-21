{ config, pkgs, ... }:
{
  networking = {
    hostName = "desktop";
    interfaces = {
      "enp42s0" = {
        wakeOnLan.enable = true;
      };
    };
  };
}
