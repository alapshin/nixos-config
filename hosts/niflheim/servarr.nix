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

  disabledModules = [
    "services/misc/sonarr.nix"
  ];

  sops = {
    templates."sonarr/api_key.env".content = ''
      SONARR__AUTH__APIKEY=${config.sops.placeholder."sonarr/api_key"}
    '';
  };

  services = {
    radarr.enable = true;
    readarr.enable = true;
    sonarr = {
      enable = true;
      auth = {
        method = "External";
        type = "DisabledForLocalAddresses";
      };
      log = {
        analyticsEnabled = false;
      };
      server = {
        host = "127.0.0.1";
      };
      postgres = {
        host = "/run/postgresql";
      };
      environmentFile = config.sops.templates."sonarr/api_key.env".path;
    };
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
        port = config.services.sonarr.server.port;
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
