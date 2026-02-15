{ pkgs, config, ... }:
let
  port = 51820;
  interface = "wg0";
  routeTable = 7777;
in
{

  sops = {
    secrets = {
      "wireguard/private_key" = {
        key = "wireguard/private_key";
        owner = config.users.users.systemd-network.name;
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ port ];
      checkReversePath = "loose";
      interfaces."${interface}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
  };

  services.vpn = {
    enable = true;
    network = "20-wg0";
    interface = interface;
    routeTable = routeTable;
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "20-wg0" = {
        netdevConfig = {
          Name = interface;
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = port;
          PrivateKeyFile = config.sops.secrets."wireguard/private_key".path;
        };
        wireguardPeers = [
          {
            Endpoint = "wg010.njalla.no:51820";
            AllowedIPs = [ "0.0.0.0/0" ];
            PublicKey = "UGz2woATzV0P1fqXZ+wjCRoZdFDJ/Kdr1aYuw25u7D4=";
            RouteTable = routeTable;
            PersistentKeepalive = 25;
          }
        ];
      };
    };
    networks = {
      "20-wg0" = {
        dns = [
          "95.215.19.53"
          "2001:67c:2354:2::53"
        ];
        address = [
          "10.13.37.228/24"
          "fd03:1337::228/64"
        ];
        matchConfig = {
          Name = interface;
        };
        networkConfig = {
          IPv6AcceptRA = false;
        };
      };
    };
  };
}
