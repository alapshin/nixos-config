{ lib
, pkgs
, config
, ...
}: {
  sops = {
    secrets = {
      "navidrome/salt" = { };
      "navidrome/token" = { };
    };
  };

  services = {
    navidrome = {
      enable = true;
      settings = {
        MusicFolder = "/mnt/data/music";
        ReverseProxyWhitelist = "127.0.0.1/8";
      };
    };
    nginx-ext.applications."navidrome" = {
      auth = true;
      port = config.services.navidrome.settings.Port;
    };
  };

  systemd = {
    tmpfiles = {
      settings = {
        "10-data-music" = {
          "/mnt/data/music" = {
            d = {
              mode = "0755";
              user = config.services.navidrome.user;
              group = config.users.groups.media.name;
            };
          };
        };
      };
    };
  };
}
