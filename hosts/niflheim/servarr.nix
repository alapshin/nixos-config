{
  lib,
  pkgs,
  config,
  ...
}:
let
  group = config.users.groups.media.name;
in
{
  disabledModules = [
    "services/misc/sonarr.nix"
    "services/misc/radarr.nix"
    "services/misc/lidarr.nix"
    "services/misc/readarr.nix"
    "services/misc/prowlarr.nix"
  ];

  sops = {
    secrets = {
      "lidarr/api_key" = { };
      "radarr/api_key" = { };
      "readarr/api_key" = { };
      "sonarr/api_key" = { };
      "prowlarr/api_key" = { };
    };
    templates."lidarr/api_key.env".content = ''
      LIDARR__AUTH__APIKEY=${config.sops.placeholder."lidarr/api_key"}
    '';
    templates."radarr/api_key.env".content = ''
      RADARR__AUTH__APIKEY=${config.sops.placeholder."radarr/api_key"}
    '';
    templates."readarr/api_key.env".content = ''
      READARR__AUTH__APIKEY=${config.sops.placeholder."readarr/api_key"}
    '';
    templates."sonarr/api_key.env".content = ''
      SONARR__AUTH__APIKEY=${config.sops.placeholder."sonarr/api_key"}
    '';
    templates."prowlarr/api_key.env".content = ''
      PROWLARR__AUTH__APIKEY=${config.sops.placeholder."prowlarr/api_key"}
    '';
  };

  services = {
    lidarr = {
      enable = true;
      dataDir = "/var/lib/lidarr";
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
      environmentFile = config.sops.templates."lidarr/api_key.env".path;
    };

    radarr = {
      enable = true;
      dataDir = "/var/lib/radarr";
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
      environmentFile = config.sops.templates."radarr/api_key.env".path;
    };

    readarr = {
      enable = true;
      dataDir = "/var/lib/readarr";
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
      environmentFile = config.sops.templates."readarr/api_key.env".path;
    };

    sonarr = {
      enable = true;
      dataDir = "/var/lib/sonarr";
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

    prowlarr = {
      enable = true;
      dataDir = "/var/lib/prowlarr";
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
      environmentFile = config.sops.templates."prowlarr/api_key.env".path;
    };

    flaresolverr = {
      enable = true;
    };

    nginx-ext.applications = {
      "lidarr" = {
        auth = true;
        port = config.services.lidarr.server.port;
      };
      "radarr" = {
        auth = true;
        port = config.services.radarr.server.port;
      };
      "readarr" = {
        auth = true;
        port = config.services.readarr.server.port;
      };
      "sonarr" = {
        auth = true;
        port = config.services.sonarr.server.port;
      };
      "prowlarr" = {
        auth = true;
        port = config.services.prowlarr.server.port;
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
    "10-music" = {
      "/mnt/data/music" = {
        d = {
          mode = "0755";
          inherit group;
          user = config.services.lidarr.user;
        };
      };
    };
  };

  users.users.radarr.extraGroups = [ group ];
  users.users.sonarr.extraGroups = [ group ];
  users.users.readarr.extraGroups = [ group ];
}
