{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.webhost;

  inherit (lib)
    types
    attrsets
    mkOption
    nameValuePair
    ;
in
{
  options.services.webhost = {
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
              type = types.nullOr types.port;
              default = null;
              description = "Application listen port.";
            };

            auth = mkOption {
              type = types.bool;
              description = "Whether to support SSO authentication.";
            };
          };
        }
      );
    };
  };

  config = {
    services.caddy.virtualHosts = attrsets.mapAttrs' (
      app: opts:
      nameValuePair "${app}.${cfg.basedomain}" {
        extraConfig = (
          builtins.concatStringsSep "\n" [
            (lib.strings.optionalString (opts.port != null) ''
              reverse_proxy :${toString opts.port}
            '')
            (lib.strings.optionalString (opts.auth) ''
              forward_auth :8001 {
                uri /api/authz/forward-auth
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
              }
            '')
          ]
        );
      }
    ) cfg.applications;
  };
}
