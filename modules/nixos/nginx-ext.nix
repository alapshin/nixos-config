{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.nginx-ext;

  inherit (lib)
    types
    attrsets
    mkIf
    mkOption
    nameValuePair
    ;
in
{
  options.services.nginx-ext = {
    basedomain = mkOption {
      type = types.str;
      description = "Base domain";
    };

    authdomain = mkOption {
      type = types.str;
      description = "Auth domain";
    };

    applications = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            port = mkOption {
              type = types.port;
              description = "Application listen port.";
            };

            auth = mkOption {
              type = types.bool;
              description = "Whether to support SSO authentication.";
            };

            proxyWebsockets = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to support proxying websocket connections with HTTP/1.1.";
            };
          };
        }
      );
    };
  };

  config = {
    services.nginx = {
      upstreams = attrsets.mapAttrs (app: opts: {
        servers = {
          "localhost:${toString opts.port}" = { };
        };
      }) cfg.applications;

      virtualHosts =
        {
          "${cfg.authdomain}" = {
            extraConfig = builtins.readFile ./nginx/auth-proxy.conf;
          };
        }
        // attrsets.mapAttrs' (
          app: opts:
          nameValuePair "${app}.${cfg.basedomain}" {
            forceSSL = true;
            useACMEHost = cfg.basedomain;
            locations = {
              "/" = {
                proxyPass = "http://${app}";
                proxyWebsockets = opts.proxyWebsockets;
                extraConfig = mkIf opts.auth (
                  lib.strings.concatStringsSep "\n" [
                    (builtins.readFile ./nginx/auth-proxy.conf)
                    (builtins.readFile ./nginx/auth-request.conf)
                  ]
                );
              };

              # Corresponds to https://www.authelia.com/integration/proxies/nginx/#authelia-locationconf
              "/internal/authelia/authz" = mkIf opts.auth {
                proxyPass = "http://authelia/api/authz/auth-request";
                extraConfig = builtins.readFile ./nginx/auth-location.conf;
              };
            };
          }
        ) cfg.applications;
    };
  };
}
