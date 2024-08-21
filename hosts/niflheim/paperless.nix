{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = config.services.paperless.port;
  dbName = config.services.paperless.user;
  dbUser = config.services.paperless.user;
  redisSocket = config.services.redis.servers."paperless".unixSocket;
in
{
  sops = {
    secrets = {
      "paperless/api_key" = { };
      "paperless/password" = { };
      "paperless/oidc_client_secret" = { };
    };
    templates."paperless.env".content = builtins.readFile (
      pkgs.substituteAll {
        src = ./paperless.env;
        server_url = "https://${config.domain.auth}";
        oidc_client_secret = config.sops.placeholder."paperless/oidc_client_secret";
      }
    );
  };

  services = {
    redis.servers."paperless" = {
      enable = true;
      port = 0;
      user = config.services.paperless.user;
      unixSocket = "/run/redis-paperless/redis.sock";
    };

    postgresql = {
      ensureDatabases = [ dbName ];
      ensureUsers = [
        {
          name = dbUser;
          ensureDBOwnership = true;
        }
      ];
    };

    nginx-ext.applications."paperless" = {
      auth = false;
      inherit port;
    };

    paperless = {
      enable = true;
      passwordFile = config.sops.secrets."paperless/password".path;
      settings = {
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_REDIS = "unix://${redisSocket}";
        PAPERLESS_ADMIN_MAIL = "admin@${config.domain.base}";
      };
    };

  };

  systemd.services.paperless-web = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."paperless.env".path;
    };
  };
}
