{ lib
, pkgs
, config
, ...
}:
let
  nextcloudHostname = "nextcloud.${config.domain.base}";
in
{
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
    nextcloud.extraGroups = [
      config.users.groups.keys.name
    ];
  };

  services = {
    nginx = {
      virtualHosts = {
        ${nextcloudHostname} = {
          forceSSL = true;
          useACMEHost = config.domain.base;
        };
      };
    };

    imaginary = {
      enable = true;
      settings.return-size = true;
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      https = true;
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
        oidc_login_provider_url = "https://auth.${config.domain.base}";
        oidc_login_attributes = {
          id = "preferred_username";
        };
        oidc_login_scope = "openid profile";
        oidc_login_button_text = "Log in with OpenID";
        oidc_login_code_challenge_method = "S256";
      };

      secretFile = config.sops.secrets."nextcloud/secrets.json".path;

      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit bookmarks calendar contacts gpoddersync tasks;
      } // {
        oidc_login = pkgs.fetchNextcloudApp {
          license = "agpl3Plus";
          url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.1.1/oidc_login.tar.gz";
          sha256 = "sha256-EVHDDFtz92lZviuTqr+St7agfBWok83HpfuL6DFCoTE=";
        };
      };
      extraAppsEnable = true;
    };
  };
}
