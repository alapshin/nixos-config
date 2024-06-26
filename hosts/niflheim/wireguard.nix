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
      "wireguard/hel_private_key" = {
        key = "wireguard/hel_private_key";
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
          PrivateKeyFile = config.sops.secrets."wireguard/hel_private_key".path;
        };
        wireguardPeers = [
          {
            Endpoint = "185.90.60.210:51820";
            AllowedIPs = [
              "0.0.0.0/0"
            ];
            PublicKey = "ievGDrxV0dKcjO7EM662c1Ziy0PVct0Ujse3CT4NQQw=";
          }
        ];
      };
    };
    networks = {
      "20-wg0" = {
        dns = [
          "10.2.0.1"
        ];
        address = [
          "10.2.0.2/32"
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
