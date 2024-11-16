{
  lib,
  pkgs,
  config,
  ...
}:
{
  disabledModules = [
    "services/web-apps/monica.nix"
  ];

  sops = {
    secrets = {
      "monica/app_key" = {
        owner = config.services.monica.user;
      };
      "monica/oidc_client_secret" = {
        owner = config.services.monica.user;
      };
    };
  };

  services = {
    monica = {
      enable = true;
      hostname = "monica.${config.domain.base}";
      appKeyFile = config.sops.secrets."monica/app_key".path;

      nginx = {
        forceSSL = true;
        useACMEHost = config.domain.base;
        locations = {
          "/register" = {
            return = "403";
          };
          "/forgot-password" = {
            return = "403";
          };
        };
      };

      database = {
        type = "pgsql";
        createLocally = true;
      };

      config = {
        APP_DEBUG = false;
        APP_DISABLE_SIGNUP = true;
        APP_SIGNUP_DOUBLE_OPTIN = false;

        MAIL_MAILER = "log";

        SCOUT_DRIVER = "database";

        AUTH_METHOD = "oidc";
        OIDC_CLIENT_ID = "monica";
        OIDC_CLIENT_SECRET = {
          _secret = config.sops.secrets."monica/oidc_client_secret".path;
        };
        OIDC_ISSUER = "https://${config.domain.auth}";
        OIDC_ISSUER_DISCOVER = true;
        OIDC_DISPLAY_NAME_CLAIMS = "name";
      };
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "monica";
              client_name = "Monica";
              client_secret = "$pbkdf2-sha512$310000$My7sx8tkZzvtMyEMcBZPcQ$tXKk03u6XIPiDC7jmAz3xyRrM/x5ftB0s3yQ9kJULBfmfK6l8jKG2eMwP2/svP0RlbiPLQzZrZmWdAy70XhqYw";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://monica.${config.domain.base}/oidc/callback"
              ];
            }
          ];
        };
      };
    };
  };
}
