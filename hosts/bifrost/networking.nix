{
  lib,
  pkgs,
  config,
  ...
}:
{
  networking = {
    hostName = "bifrost";
  };

  systemd.network = {
    # See https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
    networks."10-uplink" = {
      matchConfig.Name = "eth0 en*";
      networkConfig = {
        DHCP = "ipv4";
        Gateway = "fe80::1";
        Address = "fe80::9400:3ff:fe7e:965c/64";
      };
    };
  };

  # Network configuration i.e. when we unlock machines with openssh in the initrd
  boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";
}
