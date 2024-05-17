{ lib
, pkgs
, config
, domainName
, ...
}:
{
  systemd = {
    tmpfiles = {
      settings = {
        "10-qbittorrent" = {
          "/mnt/data/downloads" = {
            d = {
              mode = "0775";
              user = config.services.qbittorrent.user;
              group = config.users.groups.media.name;
            };
          };
        };
      };
    };
  };
}
