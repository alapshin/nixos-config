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
      settings = {
        auth = {
          method = "External";
          type = "DisabledForLocalAddresses";
        };
        log = {
          analyticsEnabled = false;
        };
        server = {
          port = 8686;
          host = "127.0.0.1";
        };
        postgres = {
          host = "/run/postgresql";
        };
      };
      environmentFiles = [
        config.sops.templates."lidarr/api_key.env".path
      ];
    };

    radarr = {
      enable = true;
      dataDir = "/var/lib/radarr";
      settings = {
        auth = {
          method = "External";
          type = "DisabledForLocalAddresses";
        };
        log = {
          analyticsEnabled = false;
        };
        server = {
          port = 7878;
          host = "127.0.0.1";
        };
        postgres = {
          host = "/run/postgresql";
        };
      };
      environmentFiles = [
        config.sops.templates."radarr/api_key.env".path
      ];
    };

    readarr = {
      enable = true;
      dataDir = "/var/lib/readarr";
      settings = {
        auth = {
          method = "External";
          type = "DisabledForLocalAddresses";
        };
        log = {
          analyticsEnabled = false;
        };
        server = {
          port = 8787;
          host = "127.0.0.1";
        };
        postgres = {
          host = "/run/postgresql";
        };
      };
      environmentFiles = [
        config.sops.templates."readarr/api_key.env".path
      ];
    };

    sonarr = {
      enable = true;
      dataDir = "/var/lib/sonarr";
      settings = {
        auth = {
          method = "External";
          type = "DisabledForLocalAddresses";
        };
        log = {
          analyticsEnabled = false;
        };
        server = {
          port = 8989;
          host = "127.0.0.1";
        };
        postgres = {
          host = "/run/postgresql";
        };
      };
      environmentFiles = [
        config.sops.templates."sonarr/api_key.env".path
      ];
    };

    prowlarr = {
      enable = true;
      settings = {
        auth = {
          method = "External";
          type = "DisabledForLocalAddresses";
        };
        log = {
          analyticsEnabled = false;
        };
        server = {
          port = 9696;
          host = "127.0.0.1";
        };
        postgres = {
          host = "/run/postgresql";
        };
      };
      environmentFiles = [
        config.sops.templates."prowlarr/api_key.env".path
      ];
    };

    flaresolverr = {
      enable = false;
    };

    postgresql = {
      ensureDatabases = [
        "lidarr-log"
        "lidarr-main"
        "radarr-log"
        "radarr-main"
        "readarr-log"
        "readarr-main"
        "readarr-cache"
        "sonarr-log"
        "sonarr-main"
        "prowlarr-log"
        "prowlarr-main"
      ];
      ensureUsers = [
        {
          name = config.services.lidarr.user;
        }
        {
          name = config.services.radarr.user;
        }
        {
          name = config.services.readarr.user;
        }
        {
          name = config.services.sonarr.user;
        }
        {
          name = config.services.prowlarr.user or "prowlarr";
        }
      ];
    };

    webhost.applications = {
      "lidarr" = {
        auth = true;
        port = config.services.lidarr.settings.server.port;
      };
      "radarr" = {
        auth = true;
        port = config.services.radarr.settings.server.port;
      };
      "readarr" = {
        auth = true;
        port = config.services.readarr.settings.server.port;
      };
      "sonarr" = {
        auth = true;
        port = config.services.sonarr.settings.server.port;
      };
      "prowlarr" = {
        auth = true;
        port = config.services.prowlarr.settings.server.port;
      };
    };
  };

  # Needed to allow Prowlarr to connect to Postgres socket
  users.users."prowlarr" = {
    group = "prowlarr";
    isSystemUser = true;
  };
  users.groups."prowlarr" = {
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

  systemd.services.postgresql.postStart = ''
    $PSQL -tAc 'ALTER DATABASE "lidarr-log" OWNER TO "lidarr";'
    $PSQL -tAc 'ALTER DATABASE "lidarr-main" OWNER TO "lidarr";'
    $PSQL -tAc 'ALTER DATABASE "radarr-log" OWNER TO "radarr";'
    $PSQL -tAc 'ALTER DATABASE "radarr-main" OWNER TO "radarr";'
    $PSQL -tAc 'ALTER DATABASE "readarr-log" OWNER TO "readarr";'
    $PSQL -tAc 'ALTER DATABASE "readarr-main" OWNER TO "readarr";'
    $PSQL -tAc 'ALTER DATABASE "readarr-cache" OWNER TO "readarr";'
    $PSQL -tAc 'ALTER DATABASE "sonarr-log" OWNER TO "sonarr";'
    $PSQL -tAc 'ALTER DATABASE "sonarr-main" OWNER TO "sonarr";'
    $PSQL -tAc 'ALTER DATABASE "prowlarr-log" OWNER TO "prowlarr";'
    $PSQL -tAc 'ALTER DATABASE "prowlarr-main" OWNER TO "prowlarr";'
  '';
}
