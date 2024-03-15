{ lib
, pkgs
, config
, domainName
, ...
}:
let
  webapp = "calibre-web";
  serverapp = "calibre-server";
  user = config.services.calibre-server.user;
  group = config.services.calibre-server.group;
  webport = config.services.calibre-web.listen.port;
  serverport = config.services.calibre-server.port;
  library = "/media/books";
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
      libraries =  [ library ];
      auth = {
        enable = true;
        # Basic auth is used because server is behind Nginx.
        # Also Koreader android app doesn't support digest auth
        # See https://github.com/koreader/koreader/issues/3953
        mode = "basic";
        userDb = config.sops.secrets."calibre/users.sqlite".path;
      };
    };
    nginx = {
      upstreams = {
        "${webapp}" = {
          servers = {
            "localhost:${toString webport}" = { };
          };
        };
        "${serverapp}" = {
          servers = {
            "localhost:${toString serverport}" = { };
          };
        };
      };

      virtualHosts = {
        "${webapp}.${domainName}" = {
          forceSSL = true;
          useACMEHost = domainName;
          locations = {
            "/" = {
              proxyPass = "http://${webapp}";
              extraConfig =
                (lib.strings.concatStringsSep "\n" [
                  (builtins.readFile ./nginx/proxy.conf)
                  (builtins.readFile ./nginx/auth-request.conf)
                ]);
              };
              "/authenticate" = {
                proxyPass = "http://authelia/api/verify";
                extraConfig = builtins.readFile ./nginx/auth-location.conf;
              };
            };
          };
        "${serverapp}.${domainName}" = {
          forceSSL = true;
          useACMEHost = domainName;
          locations = {
            "/" = {
              proxyPass = "http://${serverapp}";
            };
          };
        };
      };
    };
  };
  networking.firewall.interfaces.lo.allowedTCPPorts = [
    webport
    serverport
  ];
}
