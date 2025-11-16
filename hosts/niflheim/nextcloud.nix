{
  lib,
  pkgs,
  config,
  ...
}:
let
  nextcloudHostname = "nextcloud.${config.services.webhost.basedomain}";
in
{
  disabledModules = [ "services/web-apps/nextcloud.nix" ];

  sops = {
    secrets = {
      "nextcloud/admin_password" = {
        owner = config.users.users.nextcloud.name;
      };
      "nextcloud/secrets.json" = {
        format = "binary";
        sopsFile = ./secrets/nextcloud/secrets.json;
        owner = config.users.users.nextcloud.name;
      };
    };
  };

  users.users = {
    # Make sops keys available to nextcloud user
    nextcloud.extraGroups = [ config.users.groups.keys.name ];
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      https = true;
      webserver = "caddy";
      hostName = nextcloudHostname;

      caching.redis = true;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/admin_password".path;
      };
      database.createLocally = true;

      settings = {
        ratelimit.protection.enabled = false;

        user_oidc = {
          single_logout = false;
          auto_provision = true;
          soft_auto_provision = true;
        };

        oidc_login_client_id = "nextcloud";
        oidc_login_provider_url = "https://auth.${config.services.webhost.basedomain}";
        oidc_login_attributes = {
          id = "preferred_username";
        };
        oidc_login_scope = "openid profile";
        oidc_login_button_text = "Log in with OpenID";
        oidc_login_code_challenge_method = "S256";
      };

      secretFile = config.sops.secrets."nextcloud/secrets.json".path;

      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit
          bookmarks
          calendar
          contacts
          deck
          gpoddersync
          tasks
          ;
      };
      extraAppsEnable = true;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "nextcloud";
              client_name = "Nextcloud";
              client_secret = "$pbkdf2-sha512$310000$uLH3iUPuaccs8Ps0L7e92A$ivBv3CRJZSuYX8ARlQGWlyyIlpcqcvQl518dOqxDQ5nMRKrOSYQmGkUAlSjF3Btklbs1V6CYSXfAwlIRYjqHFg";
              require_pkce = true;
              pkce_challenge_method = "S256";
              authorization_policy = "one_factor";
              redirect_uris = [ "https://nextcloud.${config.services.webhost.basedomain}/apps/oidc_login/oidc" ];
            }
          ];
        };
      };
    };
  };
}
