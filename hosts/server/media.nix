{ config
, lib
, pkgs
, ...
}:
let
  mediaGroup = "media";
  localhost = "127.0.0.1";
  hostname = "alapshin.com";
  mkMediaService =
    { app
    , port
    , user ? null
    , group ? null
    , openFirewall ? false
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
        nginx.virtualHosts."${app}.${hostname}" = {
          forceSSL = true;
          useACMEHost = hostname;
          locations."/" = {
            proxyPass = "http://${localhost}:${builtins.toString port}";
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
          "sonarr"
          "radarr"
          "jellyfin"
          "qbittorrent"
        ];
      };
    }

    (mkMediaService { app = "bazarr"; port = 6767; })
    (mkMediaService { app = "radarr"; port = 7878; })
    (mkMediaService { app = "sonarr"; port = 8989; })
    (mkMediaService { app = "prowlarr"; port = 9696; })
    (mkMediaService { app = "jellyfin"; port = 8096; group = mediaGroup; })
    (mkMediaService { app = "jellyseerr"; port = 5055; })
    (mkMediaService { app = "qbittorrent"; port = 8080; group = mediaGroup; openFirewall = true; })
  ];
}
