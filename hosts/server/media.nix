{ lib
, pkgs
, config
, domainName
, ...
}:
let
  mediaGroup = "media";
  mkMediaService =
    { app
    , port
    , user ? null
    , group ? null
    , openFirewall ? false
    , useForwardAuth ? true
    , proxyWebsockets ? false
    }: {
      services = {
        "${app}" = {
          enable = true;
          inherit openFirewall;
        } // lib.optionalAttrs (user != null) {
          inherit user;
        } // lib.optionalAttrs (group != null) {
          inherit group;
        };
        nginx = {
          upstreams = {
            "${app}" = {
              servers = {
                "localhost:${toString port}" = { };
              };
            };
          };
          virtualHosts."${app}.${domainName}" = {
            forceSSL = true;
            useACMEHost = domainName;
            locations = {
              "/" = {
                inherit proxyWebsockets;
                proxyPass = "http://${app}";
                extraConfig =
                  if !useForwardAuth then
                    ""
                  else
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
        };
      };
      networking.firewall.interfaces.lo.allowedTCPPorts = [
        port
      ];
    };
in
{
  config = lib.mkMerge [
    {
      users.groups.media = {
        members = [
          config.services.sonarr.user
          config.services.radarr.user
          config.services.jellyfin.user
          config.services.qbittorrent.user
          config.services.audiobookshelf.user
        ];
      };
    }

    (mkMediaService {
      app = "audiobookshelf";
      port = config.services.audiobookshelf.port;
      useForwardAuth = false;
      proxyWebsockets = true;
    })
    (mkMediaService {
      app = "bazarr";
      port = config.services.bazarr.listenPort;
    })
    (mkMediaService {
      app = "radarr";
      port = 7878;
    })
    (mkMediaService {
      app = "sonarr";
      port = 8989;
    })
    (mkMediaService {
      app = "prowlarr";
      port = 9696;
    })
    (mkMediaService {
      app = "jellyfin";
      port = 8096;
      group = mediaGroup;
      useForwardAuth = false;
      proxyWebsockets = true;
    })
    (mkMediaService {
      app = "jellyseerr";
      port = 5055;
    })
    (mkMediaService {
      app = "qbittorrent";
      port = config.services.qbittorrent.port;
      group = mediaGroup;
    })
  ];
}
