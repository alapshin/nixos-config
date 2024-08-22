{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking = {
    hostName = "niflheim";

    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  systemd.network = {
    # See https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
    networks."10-uplink" = {
      matchConfig.Name = "eth en*";
      networkConfig = {
        DHCP = "ipv4";
        Gateway = "fe80::1";
        Address = "2a01:4f9:3070:2556::/64";
      };
    };
  };

  boot.initrd = {
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ /etc/ssh/ssh_initrd_ed25519_key ];
      };
    };
  };

  boot.initrd.systemd.network.enable = true;
  # Network configuration i.e. when we unlock machines with openssh in the initrd
  boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";
}
