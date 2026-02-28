{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 30000;
  hostname = "karakeep.${config.services.webhost.basedomain}";
in
{
  sops = {
    secrets = {
      "karakeep/oidc_client_secret" = { };
    };
    templates."karakeep.env".content = ''
      OAUTH_CLIENT_SECRET=${config.sops.placeholder."karakeep/oidc_client_secret"}
    '';
  };

  services = {
    karakeep = {
      enable = true;
      browser = {
        enable = false;
      };
      extraEnvironment = {
        LOG_LEVEL = "info";
        PORT = toString port;
        NEXTAUTH_URL = "https://${hostname}";
        OAUTH_CLIENT_ID = "karakeep";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_WELLKNOWN_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
        DISABLE_PASSWORD_AUTH = "true";
        DISABLE_NEW_RELEASE_CHECK = "true";
      };
      environmentFile = config.sops.templates."karakeep.env".path;
    };

    webhost.applications."karakeep" = {
      auth = false;
      port = port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          claims_policies = {
            karakeep = {
              id_token = [ "email" ];
            };
          };
          clients = [
            {
              client_id = "karakeep";
              client_name = "Karakeep";
              client_secret = "$pbkdf2-sha512$310000$rTZ5vXtOPiA0w0Gs1Ge6RA$H5vhsd1ydtDP5oH6yp4zkw.vo.mMCBHEczhUHF8nxAB9LSGoXsT538jhk4HtfYU6Ox7/Efszri95VHzK3w6w2g";
              authorization_policy = "one_factor";
              claims_policy = "karakeep";
              redirect_uris = [
                "https://${hostname}/api/auth/callback/custom"
              ];
              scopes = [
                "openid"
                "email"
                "profile"
              ];
            }
          ];
        };
      };
    };
  };
}
