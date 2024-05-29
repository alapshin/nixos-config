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
  sops = {
    secrets = {
      "audiobookshelf/api_key" = { };
    };
  };

  services = {
    audiobookshelf = {
      enable = true;
    };

    nginx.virtualHosts = {
      "audiobookshelf.${domainName}" = {
        locations."/" = {
          proxyWebsockets = true;
        };
      };
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
              mode = "0755";
              inherit group;
              user = config.services.audiobookshelf.user;
            };
          };
        };
      };
    };
  };
}
