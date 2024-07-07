{ lib
, pkgs
, config
, ...

}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    domain = mkOption {
      type = types.submodule {
        options = {
          auth = mkOption {
            type = types.str;
            description = "Public auth domain name";
          };
          base = mkOption {
            type = types.str;
            description = "Public base domain name";
          };
        };
      };
    };
  };

  config = {
    domain.base = "hlsrv.dev";
    domain.auth = "auth.${config.domain.base}";
    services.nginx-ext.basedomain = config.domain.base;
    services.nginx-ext.authdomain = config.domain.auth;
  };
}
