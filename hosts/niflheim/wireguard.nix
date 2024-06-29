{ pkgs
, config
, ...
}:
let
  wg = "wg0";
  wgPort = 51820;
  wgRouteTable = 7777;
in
{

  sops = {
    secrets = {
      "wireguard/private_key" = {
        key = "wireguard/private_key";
        owner = config.users.users.systemd-network.name;
      };
      "wireguard/preshared_key" = {
        key = "wireguard/preshared_key";
        owner = config.users.users.systemd-network.name;
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ wgPort ];
      checkReversePath = "loose";
      interfaces."${wg}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "20-wg0" = {
        netdevConfig = {
          Name = wg;
          Kind = "wireguard";
        };
        wireguardConfig = {
          ListenPort = wgPort;
          RouteTable = wgRouteTable;
          PrivateKeyFile = config.sops.secrets."wireguard/private_key".path;
        };
        wireguardPeers = [
          {
            Endpoint = "wg010.njalla.no:51820";
            AllowedIPs = [
              "0.0.0.0/0"
            ];
            PublicKey = "UGz2woATzV0P1fqXZ+wjCRoZdFDJ/Kdr1aYuw25u7D4=";
            # PresharedKeyFile = config.sops.secrets."wireguard/preshared_key".path;
            PersistentKeepalive = 25;
          }
        ];
      };
    };
    networks = {
      "20-wg0" = {
        dns = [
          "95.215.19.53"
        ];
        address = [
          "10.13.37.228/24"
        ];
        matchConfig = {
          Name = wg;
        };
        routingPolicyRules = [
          {
            Priority = 1;
            User = config.users.users.transmission.name;
            Table = "main";
            Family = "both";
            SuppressPrefixLength = 0;
          }
          {
            Priority = 2;
            User = config.users.users.transmission.name;
            Table = wgRouteTable;
            Family = "both";
          }
        ];
      };
    };
  };
}
