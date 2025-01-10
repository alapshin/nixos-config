{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
    };
  };
  services = {
    immich = {
      enable = true;
      machine-learning.enable = false;
    };

    nginx-ext.applications."immich" = {
      auth = false;
      port = config.services.immich.port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "immich";
              client_name = "Immich";
              client_secret = "$pbkdf2-sha512$310000$wkn9pc1AFRimy.bTDtULlw$ywNpmfTvmh5JP07gwLNbjH4Qa8IU5tQojXxJN2BzTxKP1r9pcbbAiik0lEgtg0uHMOMWDNZAKLg7hrHoyiPaTw";
              authorization_policy = "one_factor";
              scopes = [
                "email"
                "openid"
                "profile"
              ];
              redirect_uris = [
                "app.immich:///oauth-callback"
                "https://immich.${config.domain.base}/auth/login"
                "https://immich.${config.domain.base}/user-settings"
              ];
            }
          ];
        };
      };
    };
  };
}
