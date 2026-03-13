{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.vpn;
  inherit (lib)
    types
    mkOption
    mkIf
    mkEnableOption
    flatten
    mapAttrs'
    nameValuePair
    mapAttrsToList
    ;
in
{
  options.services.vpn = {
    enable = mkEnableOption "VPN routing for applications";

    interface = mkOption {
      type = types.str;
      description = "Wireguard interface name";
      example = "wg0";
    };

    network = mkOption {
      type = types.str;
      description = "Wireguard network name";
      example = "20-wg0";
    };

    routeTable = mkOption {
      type = types.int;
      description = "WireGuard routing table";
      example = 7777;
    };

    applications = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            user = mkOption {
              type = types.str;
              description = "Application user";
            };
          };
        }
      );
      default = { };
      description = "Applications to route through VPN";
      example = {
        bitmagnet = {
          user = "bitmagnet";
        };
        transmission = {
          user = "transmission";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Restrict service to loopback and wireguard interfaces
    systemd.services = mapAttrs' (
      app: opts:
      nameValuePair app {
        serviceConfig = {
          RestrictNetworkInterfaces = "lo ${cfg.interface}";
        };
      }
    ) cfg.applications;
    # Setup routing table for the service to route traffic via wireguard
    systemd.network.networks."${cfg.network}".routingPolicyRules = flatten (
      mapAttrsToList (app: opts: [
        {
          Priority = 1;
          User = opts.user;
          Table = "main";
          Family = "both";
          SuppressPrefixLength = 0;
        }
        {
          Priority = 2;
          User = opts.user;
          Table = cfg.routeTable;
          Family = "both";
        }
      ]) cfg.applications
    );
  };
}
