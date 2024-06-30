{ lib
, pkgs
, config
, libutil
, domainName
, ...
}:
let
  mkService = { app, description, widget ? { } }:
    let
      name = libutil.capitalize app;
      listenPort = config.services.nginx-ext.applications."${app}".port;
    in
    {
      "${name}" = {
        icon = "${app}.svg";
        href = "https://${app}.${domainName}";
        description = description;
        widget = {
          type = app;
          url = "http://localhost:${toString listenPort}";
          key = "{{HOMEPAGE_FILE_${lib.toUpper app}_API_KEY}}";
        } // widget;
      };
    };
in
{
  services = {
    homepage-dashboard = {
      enable = true;
      settings = {
        base = "https://dashboard.${domainName}";
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
          Documents = {
            style = "row";
            columns = 1;
          };
        };
      };
      services = [
        {
          Arr = [
            (mkService {
              app = "lidarr";
              description = "Music Management";
            })
            (mkService {
              app = "sonarr";
              description = "Series Management";
              widget = {
                key = "{{HOMEPAGE_FILE_SONARR_API_KEY}}";
              };
            })
            (mkService {
              app = "radarr";
              description = "Movies Management";
              widget = {
                key = "{{HOMEPAGE_FILE_RADARR_API_KEY}}";
              };
            })
            (mkService {
              app = "readarr";
              description = "Ebooks Management";
              widget = {
                key = "{{HOMEPAGE_FILE_READARR_API_KEY}}";
              };
            })
            (mkService {
              app = "prowlarr";
              description = "Indexer Management";
              widget = {
                key = "{{HOMEPAGE_FILE_PROWLARR_API_KEY}}";
              };
            })
            (mkService {
              app = "transmission";
              description = "Torrent Management";
            })
          ];
        }
        {
          Media = [
            (mkService {
              app = "audiobookshelf";
              description = "Audiobook and podcast server";
            })
            (mkService {
              app = "jellyfin";
              description = "The Free Software Media System ";
            })
            # (mkService {
            #   app = "jellyseer" ;
            #   description = "Media request management";
            # })
          ];
        }
        {
          Documents = [
            (mkService {
              app = "paperless";
              widget = {
                type = "paperlessngx";
              };
              description = "Document management system";
            })
          ];
        }
      ];
    };

    nginx-ext.applications."dashboard" = {
      auth = true;
      port = config.services.homepage-dashboard.listenPort;
    };
  };

  systemd.services.homepage-dashboard = {
    environment = {
      LOG_LEVEL = "debug";
      HOMEPAGE_FILE_AUDIOBOOKSHELF_API_KEY = "%d/audiobookshelf_api_key";
      HOMEPAGE_FILE_LIDARR_API_KEY = "%d/lidarr_api_key";
      HOMEPAGE_FILE_SONARR_API_KEY = "%d/sonarr_api_key";
      HOMEPAGE_FILE_RADARR_API_KEY = "%d/radarr_api_key";
      HOMEPAGE_FILE_READARR_API_KEY = "%d/readarr_api_key";
      HOMEPAGE_FILE_PROWLARR_API_KEY = "%d/prowlarr_api_key";
      HOMEPAGE_FILE_JELLYFIN_API_KEY = "%d/jellyfin_api_key";
      HOMEPAGE_FILE_JELLYSEERR_API_KEY = "%d/jellyseerr_api_key";
      HOMEPAGE_FILE_PAPERLESS_API_KEY = "%d/paperless_api_key";
    };
    serviceConfig = {
      LoadCredential = [
        "audiobookshelf_api_key:${config.sops.secrets."audiobookshelf/api_key".path}"

        "lidarr_api_key:${config.sops.secrets."lidarr/api_key".path}"
        "radarr_api_key:${config.sops.secrets."radarr/api_key".path}"
        "readarr_api_key:${config.sops.secrets."readarr/api_key".path}"
        "sonarr_api_key:${config.sops.secrets."sonarr/api_key".path}"
        "prowlarr_api_key:${config.sops.secrets."prowlarr/api_key".path}"

        "jellyfin_api_key:${config.sops.secrets."jellyfin/api_key".path}"
        "jellyseerr_api_key:${config.sops.secrets."jellyseerr/api_key".path}"

        "paperless_api_key:${config.sops.secrets."paperless/api_key".path}"
      ];
    };
  };
}
