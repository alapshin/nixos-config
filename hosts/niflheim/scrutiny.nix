{ lib, config, ... }:
let
  org = "homelab";
  bucket = "scrutiny";
in
{
  sops = {
    templates."scrutiny/influxdb_token.env".content = ''
      SCRUTINY_WEB_INFLUXDB_TOKEN=${config.sops.placeholder."influxdb/admin_token"}
    '';
  };
  services = {
    scrutiny = {
      enable = true;
      collector = {
        enable = true;
      };
      settings = {
        log.level = "DEBUG";
        web = {
          listen.host = "127.0.0.1";
          influxdb = {
            enable = true;
            inherit org bucket;
            host = "127.0.0.1";
          };
        };
      };
    };

    nginx-ext.applications."scrutiny" = {
      auth = true;
      port = config.services.scrutiny.settings.web.listen.port;
    };
  };

  systemd.services.scrutiny.serviceConfig = {
    EnvironmentFile = config.sops.templates."scrutiny/influxdb_token.env".path;
  };
}
