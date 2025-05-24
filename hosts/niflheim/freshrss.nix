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
      "freshrss/oidc_client_secret" = {
      };

    };
    templates."freshrss.env".content = ''
      OIDC_CLIENT_SECRET=config.sops.placeholder."paperless/oidc_client_secret";
      OIDC_CLIENT_CRYPTO_KEY=insecure_crypto_key
    '';
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

    webhost.applications."freshrss" = {
      auth = true;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "freshrss";
              client_name = "FreshRSS";
              client_secret = "$pbkdf2-sha512$310000$xQ8NO2Qe0ugYdsYKEEXgJQ$e0ziGtIgAChw958WaYShQAEXOPW/.WL9SHN77xpHqKam.NpqA7ncbB/URJkaVewLwufMkxLailAu1H0M5ufpcg";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://freshrss.${config.services.webhost.basedomain}/i/oidc/"
              ];
            }
          ];
        };
      };
    };
  };

  systemd.services.phpfpm-freshrss.environment = {
    OIDC_ENABLED = "1";
    OIDC_CLIENT_ID = "freshrss";
    OIDC_PROVIDER_METADATA_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
    OIDC_SCOPES = "openid groups email profile";
    OIDC_REMOTE_USER_CLAIM = "preferred_username";
    OIDC_X_FORWARDED_HEADERS="X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
  };

  systemd.services.freshrss-config.environment = {
    OIDC_ENABLED = "1";
    OIDC_CLIENT_ID = "freshrss";
    OIDC_PROVIDER_METADATA_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
    OIDC_SCOPES = "openid groups email profile";
    OIDC_REMOTE_USER_CLAIM = "preferred_username";
    OIDC_X_FORWARDED_HEADERS="X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
  };
}
