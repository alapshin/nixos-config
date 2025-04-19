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
        server_url = "https://${config.services.webhost.authdomain}";
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

    paperless = {
      enable = true;
      passwordFile = config.sops.secrets."paperless/password".path;
      settings = {
        PAPERLESS_URL = "https://paperless.${config.services.webhost.basedomain}";
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_REDIS = "unix://${redisSocket}";
        PAPERLESS_ADMIN_MAIL = "admin@${config.services.webhost.basedomain}";
      };
    };

    webhost.applications."paperless" = {
      auth = false;
      inherit port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "paperless";
              client_name = "Paperless";
              client_secret = "$pbkdf2-sha512$310000$ylijOhbBagCwDiaNWPM2GA$mpdcyzbOgih92PY3WQO8x8BiZSLZu33uojolXe5hg/H.U71a.HGTY168YOcBz1TYeYqyCvY2s7jSW86Gb8qtUg";
              require_pkce = true;
              pkce_challenge_method = "S256";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://paperless.${config.services.webhost.basedomain}/accounts/oidc/authelia/login/callback/"
              ];
            }
          ];
        };
      };
    };

  };

  systemd.services.paperless-web = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."paperless.env".path;
    };
  };
}
