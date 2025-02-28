{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "audiobookshelf/api_key" = { };
    };
  };

  services = {
    audiobookshelf = {
      enable = true;
    };

    webhost.applications."audiobookshelf" = {
      auth = false;
      port = config.services.audiobookshelf.port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "audiobookshelf";
              client_name = "Audiobookshelf";
              client_secret = "$pbkdf2-sha512$310000$CYG9RzneGw4EEojmAFaprA$CppTSc1wUVwvVtkD48.UFO7KPMAN9OlHIOMnuNeDAyvTSNXshShlcONmQinyd.D8DaOTGE0Sn.wWqEYRWnq9hg";
              require_pkce = true;
              pkce_challenge_method = "S256";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://audiobookshelf.${config.services.webhost.basedomain}/auth/openid/callback"
                "https://audiobookshelf.${config.services.webhost.basedomain}/auth/openid/mobile-redirect"
              ];
            }
          ];
        };
      };
    };

  };

  systemd = {
    tmpfiles = {
      settings = {
        "10-audiobookshelf" = {
          "/mnt/data/audiobooks" = {
            d = {
              mode = "0755";
              user = config.services.audiobookshelf.user;
              group = config.users.groups.media.name;
            };
          };
        };
      };
    };
  };
}
