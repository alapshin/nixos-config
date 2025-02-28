{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostname = "freshrss.${config.services.webhost.basedomain}";
in
{

  sops = {
    secrets = {
      "freshrss/admin_password" = {
        owner = config.services.freshrss.user;
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
      webserver = "caddy";
      virtualHost = "${hostname}";
      passwordFile = config.sops.secrets."freshrss/admin_password".path;
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
