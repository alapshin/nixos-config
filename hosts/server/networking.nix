{ config
, pkgs
, ...
}: {
  networking = {
    useDHCP = false;
    hostName = "homeserver";
    dhcpcd.enable = false;
    firewall = {
      enable = true;
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ 80 443 ];
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        name = "enp0s18";
        dns = [
          "1.1.1.1"
          "2606:4700:4700::1111"
        ];
        DHCP = "no";
        address = [
          "212.193.3.249/24"
          "2602:fb54:143::22/48"
        ];
        gateway = [
          "212.193.3.1"
          "2602:fb54:143::1"
        ];
      };
    };
  };
}
