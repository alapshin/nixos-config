{ lib
, pkgs
, config
, domainName
, ...
}:
let
in
{
  systemd = {
    tmpfiles = {
      settings = {
        "10-audiobookshelf" = {
          "/media/audiobooks" = {
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