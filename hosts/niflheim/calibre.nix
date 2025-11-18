# Setup calibre-server and calibre-web
{
  lib,
  pkgs,
  config,
  ...
}:
let
  libraryDir = "/mnt/data/books";
  user = config.services.calibre-server.user;
  group = config.services.calibre-server.group;
  port = config.services.calibre-web.listen.port;
  metadataFilePath = builtins.path {
    path = ./calibre/metadata.db;
    name = "calibre-server-metadata";
  };
  cwaDataDir = "/var/lib/calibre-web-automated";
  cwaConfigDir = "${cwaDataDir}/config";
  cwaIngestDir = "${cwaDataDir}/ingest";
in
{
  sops = {
    secrets = {
      "calibre/users.sqlite" = {
        owner = user;
        format = "binary";
        sopsFile = ./secrets/calibre/users.sqlite;
      };
      "calibreweb/admin_username" = { };
      "calibreweb/admin_password" = { };
    };
  };
  services = {
    # calibre-web = {
    #   enable = true;
    #   user = user;
    #   group = group;
    #   listen.ip = "127.0.0.1";
    #   options = {
    #     calibreLibrary = library;
    #     reverseProxyAuth = {
    #       enable = true;
    #       header = "Remote-User";
    #     };
    #   };
    # };

    calibre-server = {
      enable = true;
      port = 8081;
      host = "127.0.0.1";
      libraries = [ libraryDir ];
      auth = {
        enable = true;
        # Basic auth is used because server is behind Nginx.
        # Also Koreader android app doesn't support digest auth
        # See https://github.com/koreader/koreader/issues/3953
        mode = "basic";
        userDb = config.sops.secrets."calibre/users.sqlite".path;
      };
    };

    backup.jobs.books.paths = [
      libraryDir
    ];

    webhost.applications = {
      "calibre" = {
        auth = true;
        port = port;
      };
      "cwacomp" = {
        auth = false;
        port = port;
      };
    };
  };

  systemd = {
    tmpfiles = {
      settings = {
        # Setup calibre library directory
        "10-calibre-server" = {
          libraryDir = {
            d = {
              mode = "0775";
              user = user;
              group = "media";
            };
          };
          # Place empty metadata databest into library directory
          "${libraryDir}/metadata.db" = {
            Z = {
              mode = "0664";
              user = user;
              group = "media";
            };
            C = {
              argument = builtins.toString metadataFilePath;
            };
          };
        };
        "20-calibre-web-automated" = {
          "${cwaConfigDir}" = {
            d = {
              mode = "0775";
              user = user;
              group = "media";
            };
          };
          "${cwaIngestDir}" = {
            d = {
              mode = "0775";
              user = user;
              group = "media";
            };
          };
        };
      };
    };
  };

  virtualisation.oci-containers.containers."calibre-web-automated" = {
    image = "crocodilestick/calibre-web-automated:V3.1.4";
    ports = [
      "127.0.0.1:${builtins.toString port}:8083/tcp"
    ];
    volumes = [
      "${libraryDir}:/calibre-library:rw"
      "${cwaConfigDir}:/config:rw"
      "${cwaIngestDir}:/cwa-book-ingest:rw"
    ];
    environment = {
      TZ = "UTC";
      PUID = builtins.toString config.users.users."calibre-server".uid;
      PGID = builtins.toString config.users.groups."calibre-server".gid;
    };
    log-driver = "journald";
  };
}
