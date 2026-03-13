{
  lib,
  pkgs,
  config,
  publicIPv4,
  ...
}:
{
  networking = {
    hostName = "midgard";
  };

  systemd.network = {
    # See https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
    networks."10-uplink" = {
      matchConfig.Name = "eth0 en*";
      networkConfig.DHCP = "no";
      address = [
        "${publicIPv4}/24"
        "2602:fb54:1800::5/128"
      ];
      routes = [
        {
          routeConfig = {
            Gateway = "212.193.3.1";
          };
        }
        {
          routeConfig = {
            Gateway = "2602:fb54:1800::1";
            GatewayOnLink = true;
          };
        }
        {
          routeConfig = {
            Gateway = "2602:fb54:1800::5";
            Destination = "2602:fb54:1804::/48";
          };
        }
      ];
    };
  };

  # Network configuration i.e. when we unlock machines with openssh in the initrd
  boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";
}
