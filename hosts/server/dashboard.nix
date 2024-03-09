{ lib
, pkgs
, config
, domainName
, ...
}:
let
  app = "dashboard";
  port = config.services.homepage-dashboard.listenPort;
in
{
  sops = {
    secrets = {
      "jellyfin/api_key" = { };
      "jellyseerr/api_key" = { };
      "radarr/api_key" = { };
      "sonarr/api_key" = { };
      "prowlarr/api_key" = { };
      "qbittorrent/username" = { };
      "qbittorrent/password" = { };
    };
  };
  services = {
    homepage-dashboard = {
      enable = true;
      settings = {
        theme = "dark";
        hideVersion = true;
        headerStyle = "clean";
        useEqualHeights = true;
        layout = {
          Arr = {
            style = "row";
            columns = 4;
          };
          Media = {
            style = "row";
            columns = 2;
          };
        };
      };
      services = [
        {
          Arr = [
            {
              Sonarr = {
                icon = "sonarr.svg";
                href = "https://sonarr.${domainName}";
                description = "Series Management";
                widget = {
                  type = "sonarr";
                  url = "https://sonarr.${domainName}";
                  key = "{{HOMEPAGE_FILE_SONARR_API_KEY}}";
                };
              };
            }
            {
              Radarr = {
                icon = "radarr.svg";
                href = "https://radarr.${domainName}";
                description = "Movies Management";
                widget = {
                  type = "radarr";
                  url = "https://radarr.${domainName}";
                  key = "{{HOMEPAGE_FILE_RADARR_API_KEY}}";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr.svg";
                href = "https://prowlarr.${domainName}";
                description = "Indexer Management";
                widget = {
                  type = "prowlarr";
                  url = "https://prowlarr.${domainName}";
                  key = "{{HOMEPAGE_FILE_PROWLARR_API_KEY}}";
                };
              };
            }
            {
              qBittorrent = {
                icon = "qbittorrent.svg";
                href = "https://qbittorrent.${domainName}";
                description = "Torrent Management";
                widget = {
                  type = "qbittorrent";
                  url = "https://qbittorrent.${domainName}";
                  username = "{{HOMEPAGE_FILE_QBITTORRENT_USERNAME}}";
                  password = "{{HOMEPAGE_FILE_QBITTORRENT_PASSWORD}}";
                };
              };
            }
          ];
        }
        {
          Media = [
            {
              Jellyfin = {
                icon = "jellyfin.svg";
                href = "https://jellyfin.${domainName}";
                description = "Media System";
                widget = {
                  type = "jellyfin";
                  url = "https://jellyfin.${domainName}";
                  key = "{{HOMEPAGE_FILE_JELLYFIN_API_KEY}}";
                  enableBlocks = true;
                  enableNowPlaying = false;
                };
              };
            }
            {
              Jellyseer = {
                icon = "jellyseerr.svg";
                href = "https://jellyseerr.${domainName}";
                description = "Media request management";
                widget = {
                  type = "jellyseerr";
                  url = "https://jellyseerr.${domainName}";
                  key = "{{HOMEPAGE_FILE_JELLYSEERR_API_KEY}}";
                };
              };
            }
          ];
        }
      ];
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
            proxyPass = "http://${app}";
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
    };
  };
  networking.firewall.interfaces.lo.allowedTCPPorts = [
    port
  ];
  systemd.services.homepage-dashboard = {
    environment = {
      HOMEPAGE_FILE_SONARR_API_KEY = "%d/sonarr_api_key";
      HOMEPAGE_FILE_RADARR_API_KEY = "%d/radarr_api_key";
      HOMEPAGE_FILE_PROWLARR_API_KEY = "%d/prowlarr_api_key";
      HOMEPAGE_FILE_JELLYFIN_API_KEY = "%d/jellyfin_api_key";
      HOMEPAGE_FILE_JELLYSEERR_API_KEY = "%d/jellyseerr_api_key";
      HOMEPAGE_FILE_QBITTTORRENT_USERNAME = "%d/qbittorrent_username";
      HOMEPAGE_FILE_QBITTTORRENT_PASSWORD = "%d/qbittorrent_password";
    };
    serviceConfig = {
      LoadCredential = [
        "radarr_api_key:${config.sops.secrets."radarr/api_key".path}"
        "sonarr_api_key:${config.sops.secrets."sonarr/api_key".path}"
        "prowlarr_api_key:${config.sops.secrets."prowlarr/api_key".path}"
        "jellyfin_api_key:${config.sops.secrets."jellyfin/api_key".path}"
        "jellyseerr_api_key:${config.sops.secrets."jellyseerr/api_key".path}"
        "qbittorrent_username:${config.sops.secrets."qbittorrent/username".path}"
        "qbittorrent_password:${config.sops.secrets."qbittorrent/password".path}"
      ];
    };
  };
}
