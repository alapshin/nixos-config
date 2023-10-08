{ config
, pkgs
, ...
}: {
  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 1080 ];
      allowedTCPPorts = [ 80 443 1080 8443 ];
    };
    enableIPv6 = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        name = "enp0s18";
        dns = [
          "8.8.8.8"
        ];
        DHCP = "no";
        address = [
          "212.193.3.249/24"
          # "fe80:dca0:dcff:fe5f:2c1a/64"
        ];
        gateway = [
          "212.193.3.1"
        ];
      };
    };
  };
}
