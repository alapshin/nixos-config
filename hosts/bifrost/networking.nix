{
  lib,
  pkgs,
  config,
  ...
}:
{
  networking = {
    hostName = "bifrost";
    firewall = {
      enable = true;
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
    useNetworkd = true;
  };
  systemd.network = {
    enable = true;

    # See https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
    networks."10-wan" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        Gateway = "fe80::1";
        Address = "fe80::9400:3ff:fe7e:965c/64";
      };
    };
  };
}
