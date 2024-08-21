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

    nginx-ext.applications."audiobookshelf" = {
      auth = false;
      port = config.services.audiobookshelf.port;
      proxyWebsockets = true;
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
