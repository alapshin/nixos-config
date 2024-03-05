{ lib
, pkgs
, config
, domainName
, ...
}: let 
  port = config.services.paperless.port;
  dbName = config.services.paperless.user;
  dbUser = config.services.paperless.user;
  redisSocket = config.services.redis.servers."paperless".unixSocket;
in {
  sops = {
    secrets = {
      "paperless/password" = { };
      "paperless/oidc_client_secret" = { };
    };
    templates."paperless.env".content = builtins.readFile (pkgs.substituteAll {
      src = ./paperless.env;
      oidc_client_secret = config.sops.placeholder."paperless/oidc_client_secret";
    });
  };

  services = {
    paperless = {
      enable = true;
      passwordFile = config.sops.secrets."paperless/password".path;
      settings = {
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_REDIS = "unix://${redisSocket}";
        PAPERLESS_ADMIN_MAIL = "admin@${domainName}";
      };
    };

    nginx = {
      upstreams = {
        "paperless" = {
          servers = {
            "localhost:${toString port}" = { };
          };
        };
      };

      virtualHosts = {
        "paperless.${domainName}" = {
          forceSSL = true;
          useACMEHost = domainName;

          locations = {
            "/" = {
              proxyPass = "http://paperless";
              extraConfig = builtins.readFile ./nginx/proxy.conf;
            };
          };
        };
      };
    };

    redis.servers."paperless" = {
      enable = true;
      port = 0;
      user = config.services.paperless.user;
      unixSocket = "/run/redis-paperless/redis.sock";
    };

    postgresql = {
      ensureDatabases = [
        dbName
      ];
      ensureUsers = [
        {
          name = dbUser;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  systemd.services.paperless-web = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."paperless.env".path;
    };
  };
}
