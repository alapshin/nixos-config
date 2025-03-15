{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "photoprism/admin_username" = { };
      "photoprism/admin_password" = { };
      "photoprism/oidc_client_secret" = { };
    };
    templates."photoprism.env".content = ''
      PHOTOPRISM_OIDC_SECRET=${config.sops.placeholder."photoprism/oidc_client_secret"}
    '';
  };

  services = {
    photoprism = {
      enable = false;
      originalsPath = "/mnt/data/photos";
      passwordFile = config.sops.secrets."photoprism/admin_password".path;
      settings = {
        PHOTOPRISM_OIDC_WEBDAV = "true";
        PHOTOPRISM_OIDC_REGISTER = "true";
        PHOTOPRISM_OIDC_URI = "https://${config.services.webhost.authdomain}";
        PHOTOPRISM_OIDC_CLIENT = "photoprism";
        PHOTOPRISM_OIDC_PROVIDER = "Authelia";

        PHOTOPRISM_SITE_URL = "https://photoprism.${config.services.webhost.basedomain}";
      };
    };

    webhost.applications."photoprism" = {
      auth = false;
      port = config.services.photoprism.port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "photoprism";
              client_name = "PhotoPrism";
              client_secret = "$pbkdf2-sha512$310000$p3cinO7wg61tGTLjc9u4Fw$sMP0JHSEPyQjQeDzCPJamQ08fz.ulv7neS3nwU2ZM8zMNMSfn3EI7l1RIOrkUZe.bT.RKXcQz/SjjpwtUnNMMg";
              authorization_policy = "one_factor";
              scopes = [
                "address"
                "email"
                "groups"
                "openid"
                "profile"
              ];
              redirect_uris = [
                "https://photoprism.${config.services.webhost.basedomain}/api/v1/oidc/redirect"
              ];
            }
          ];
        };
      };
    };
  };

  systemd.tmpfiles.settings = {
    "10-photoprism" = {
      "/mnt/data/photos" = {
        d = {
          mode = "0755";
        };
      };
    };
  };

  systemd.services.photoprism.serviceConfig = {
    EnvironmentFile = config.sops.templates."photoprism.env".path;
  };

}
