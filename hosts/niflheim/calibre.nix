{ lib
, pkgs
, config
, domainName
, ...
}:
let
  library = "/mnt/data/books";
  user = config.services.calibre-server.user;
  group = config.services.calibre-server.group;
  webport = config.services.calibre-web.listen.port;
  serverport = config.services.calibre-server.port;
  metadataFilePath = builtins.path {
    path = ./calibre/metadata.db;
    name = "calibre-server-metadata";
  };
in
{
  sops = {
    secrets = {
      "calibre/users.sqlite" = {
        owner = user;
        format = "binary";
        sopsFile = ./secrets/calibre/users.sqlite;
      };
    };
  };
  services = {
    calibre-web = {
      enable = true;
      user = user;
      group = group;
      listen.ip = "127.0.0.1";
      options = {
        calibreLibrary = library;
        reverseProxyAuth = {
          enable = true;
          header = "Remote-User";
        };
      };
    };

    calibre-server = {
      enable = true;
      port = 8081;
      host = "127.0.0.1";
      libraries = [ library ];
      auth = {
        enable = true;
        # Basic auth is used because server is behind Nginx.
        # Also Koreader android app doesn't support digest auth
        # See https://github.com/koreader/koreader/issues/3953
        mode = "basic";
        userDb = config.sops.secrets."calibre/users.sqlite".path;
      };
    };

    nginx-ext.applications = {
      "calibre-web" = {
        port = webport;
      };
      "calibre-server" = {
        port = serverport;
      };
    };
  };

  systemd = {
    tmpfiles = {
      settings = {
        "10-calibre-server" = {
          "/mnt/data/books" = {
            d = {
              mode = "0775";
              user = user;
              group = "media";
            };
          };
          "/mnt/data/books/metadata.db" = {
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
      };
    };
  };
}
