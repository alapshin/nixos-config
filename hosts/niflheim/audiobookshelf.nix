{ lib
, pkgs
, config
, domainName
, ...
}: {
  services = {
    audiobookshelf = {
      enable = true;
    };

    nginx-ext.applications."audiobookshelf" = {
      auth = false;
      port = config.services.audiobookshelf.port;
    };
  };

  systemd = {
    tmpfiles = {
      settings = {
        "10-audiobookshelf" = {
          "/mnt/data/audiobooks" = {
            d = {
              mode = "0775";
              user = config.services.audiobookshelf.user;
              group = config.users.groups.media.name;
            };
          };
        };
      };
    };
  };
}
