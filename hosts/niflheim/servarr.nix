{ lib
, pkgs
, config
, domainName
, ...
}:
let
  group = config.users.groups.media.name;
in
{
  services = {
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;

    nginx-ext.applications = {
      "radarr" = {
        auth = true;
        port = 7878;
      };
      "readarr" = {
        auth = true;
        port = 8787;
      };
      "sonarr" = {
        auth = true;
        port = 8989;
      };
      "prowlarr" = {
        auth = true;
        port = 9696;
      };
    };
  };

  systemd.tmpfiles.settings = {
    "10-movies" = {
      "/mnt/data/movies" = {
        d = {
          mode = "0755";
          inherit group;
          user = config.services.radarr.user;
        };
      };
    };
    "10-tvshows" = {
      "/mnt/data/tvshows" = {
        d = {
          mode = "0755";
          inherit group;
          user = config.services.sonarr.user;
        };
      };
    };
  };

  users.users.radarr.extraGroups = [ group ];
  users.users.sonarr.extraGroups = [ group ];
  users.users.readarr.extraGroups = [ group ];
}
