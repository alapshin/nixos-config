{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostname = "freshrss.${config.domain.base}";
in
{

  sops = {
    secrets = {
      "freshrss/admin_password" = {
        owner = "freshrss";
      };
    };
  };
  services = {
    freshrss = {
      enable = true;
      authType = "form";
      baseUrl = "https://${hostname}";
      database = {
        type = "pgsql";
        host = "/run/postgresql";

      };
      virtualHost = "${hostname}";
      passwordFile = config.sops.secrets."freshrss/admin_password".path;
    };

    nginx.virtualHosts."${hostname}" = {
      forceSSL = true;
      useACMEHost = config.domain.base;
    };

    postgresql = {
      ensureDatabases = [ config.services.freshrss.database.name ];
      ensureUsers = [
        {
          name = config.services.freshrss.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
