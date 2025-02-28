{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostname = "monica.${config.services.webhost.basedomain}";
in
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
      hostname = hostname;
      appKeyFile = config.sops.secrets."monica/app_key".path;

      database = {
        type = "pgsql";
        createLocally = true;
      };
      webserver = "caddy";

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
        OIDC_ISSUER = "https://${config.services.webhost.authdomain}";
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
                "https://monica.${config.services.webhost.basedomain}/oidc/callback"
              ];
            }
          ];
        };
      };
    };

    caddy.virtualHosts."${hostname}".extraConfig = ''
      respond /register 403
      respond /forgot-password 403
    '';
  };
}
