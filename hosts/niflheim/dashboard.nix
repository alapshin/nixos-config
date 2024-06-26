{ lib
, pkgs
, config
, domainName
, ...
}:
let
  port = config.services.homepage-dashboard.listenPort;
in
{
  sops = {
    secrets = {
      "jellyfin/api_key" = { };
      "jellyseerr/api_key" = { };
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
          Documents = {
            style = "row";
            columns = 1;
          };
        };
      };
      services = [
        {
          Arr = [
            {
              Lidarr = {
                icon = "lidarr.svg";
                href = "https://lidarr.${domainName}";
                description = "Series Management";
                widget = {
                  type = "lidarr";
                  url = "https://lidarr.${domainName}";
                  key = "{{HOMEPAGE_FILE_LIDARR_API_KEY}}";
                };
              };
            }
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
              Readarr = {
                icon = "readarr.svg";
                href = "https://readarr.${domainName}";
                description = "Books Management";
                widget = {
                  type = "readarr";
                  url = "https://readarr.${domainName}";
                  key = "{{HOMEPAGE_FILE_READARR_API_KEY}}";
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
              Transmission = {
                icon = "transmission.svg";
                href = "https://transmission.${domainName}";
                description = "Torrent Management";
                widget = {
                  type = "transmission";
                  url = "https://transmission.${domainName}";
                };
              };
            }
          ];
        }
        {
          Media = [
            {
              Audiobookshelf = {
                icon = "audiobookshelf.svg";
                href = "https://audiobookshelf.${domainName}";
                description = "Audiobook and podcast server ";
                widget = {
                  type = "audiobookshelf";
                  url = "https://audiobookshelf.${domainName}";
                  key = "{{HOMEPAGE_FILE_AUDIOBOOKSHELF_API_KEY}}";
                  enableBlocks = true;
                  enableNowPlaying = false;
                };
              };
            }
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
        {
          Documents = [
            {
              Paperless = {
                icon = "paperless-ngx.svg";
                href = "https://paperless.${domainName}";
                description = "Document management system";
                widget = {
                  type = "paperlessngx";
                  url = "https://paperless.${domainName}";
                  key = "{{HOMEPAGE_FILE_PAPERLESS_API_KEY}}";
                };
              };
            }
          ];
        }
      ];
    };

    nginx-ext.applications."dashboard" = {
      auth = true;
      inherit port;
    };
  };

  systemd.services.homepage-dashboard = {
    environment = {
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
