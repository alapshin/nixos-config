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
            columns = 2;
          };
          Monitoring = {
            style = "row";
            columns = 2;
          };
        };
      };
      widgets = [
        {
          datetime = {
            text_size = "xl";
            format = {
              hour12 = false;
              dateStyle = "long";
              timeStyle = "long";
            };
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
          };
        }
      ];
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
              app = "calibre";
              description = "Browse, read and download eBooks";
              widget = {
                type = "calibreweb";
                username = "{{HOMEPAGE_FILE_CALIBREWEB_USERNAME}}";
                password = "{{HOMEPAGE_FILE_CALIBREWEB_PASSWORD}}";
              };
            })
            (mkService {
              app = "jellyfin";
              description = "The Free Software Media System";
            })
            (mkService {
              app = "navidrome";
              description = "Modern Music Server and Streamer";
              widget = {
                user = "admin";
                salt = "{{HOMEPAGE_FILE_NAVIDROME_SALT}}";
                token = "{{HOMEPAGE_FILE_NAVIDROME_TOKEN}}";
              };
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
              app = "nextcloud";
              description = "A safe home for all your data";
              widget = {
                url = "https://nextcloud.${domainName}";
                key = null;
                username = "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}";
                password = "{{HOMEPAGE_FILE_NEXTCLOUD_PASSWORD}}";
              };
            })
            (mkService {
              app = "paperless";
              widget = {
                type = "paperlessngx";
              };
              description = "Community-supported open-source document management system";
            })
            (mkService {
              app = "photoprism";
              description = "AI-Powered Photos App for the Decentralized Web";
              widget = {
                username = "{{HOMEPAGE_FILE_PHOTOPRISM_USERNAME}}";
                password = "{{HOMEPAGE_FILE_PHOTOPRISM_PASSWORD}}";
              };
            })
          ];
        }
        {
          Monitoring = [
            (mkService {
              app = "prometheus";
              description = "Monitoring system and time series database";
            })
            (mkService {
              app = "grafana";
              description = "The open and composable observability and data visualization platform";
              widget = {
                username = "{{HOMEPAGE_FILE_GRAFANA_USERNAME}}";
                password = "{{HOMEPAGE_FILE_GRAFANA_PASSWORD}}";
              };
            })
            (mkService {
              app = "scrutiny";
              description = "Hard Drive S.M.A.R.T Monitoring, Historical Trends & Real World Failure Thresholds";
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
      HOMEPAGE_FILE_CALIBREWEB_USERNAME = "%d/calibreweb_username";
      HOMEPAGE_FILE_CALIBREWEB_PASSWORD = "%d/calibreweb_password";

      HOMEPAGE_FILE_GRAFANA_USERNAME = "%d/grafana_username";
      HOMEPAGE_FILE_GRAFANA_PASSWORD = "%d/grafana_password";

      HOMEPAGE_FILE_LIDARR_API_KEY = "%d/lidarr_api_key";
      HOMEPAGE_FILE_SONARR_API_KEY = "%d/sonarr_api_key";
      HOMEPAGE_FILE_RADARR_API_KEY = "%d/radarr_api_key";
      HOMEPAGE_FILE_READARR_API_KEY = "%d/readarr_api_key";
      HOMEPAGE_FILE_PROWLARR_API_KEY = "%d/prowlarr_api_key";
      HOMEPAGE_FILE_JELLYFIN_API_KEY = "%d/jellyfin_api_key";
      HOMEPAGE_FILE_JELLYSEERR_API_KEY = "%d/jellyseerr_api_key";

      HOMEPAGE_FILE_NAVIDROME_SALT = "%d/navidrome_salt";
      HOMEPAGE_FILE_NAVIDROME_TOKEN = "%d/navidrome_token";

      HOMEPAGE_VAR_NEXTCLOUD_USERNAME = config.services.nextcloud.config.adminuser;
      HOMEPAGE_FILE_NEXTCLOUD_PASSWORD = "%d/nextcloud_password";

      HOMEPAGE_FILE_PAPERLESS_API_KEY = "%d/paperless_api_key";
      HOMEPAGE_FILE_PHOTOPRISM_USERNAME = "%d/photoprism_username";
      HOMEPAGE_FILE_PHOTOPRISM_PASSWORD = "%d/photoprism_password";
    };
    serviceConfig = {
      LoadCredential = [
        "audiobookshelf_api_key:${config.sops.secrets."audiobookshelf/api_key".path}"
        "calibreweb_username:${config.sops.secrets."calibreweb/admin_username".path}"
        "calibreweb_password:${config.sops.secrets."calibreweb/admin_password".path}"


        "grafana_username:${config.sops.secrets."grafana/admin_username".path}"
        "grafana_password:${config.sops.secrets."grafana/admin_password".path}"

        "lidarr_api_key:${config.sops.secrets."lidarr/api_key".path}"
        "radarr_api_key:${config.sops.secrets."radarr/api_key".path}"
        "readarr_api_key:${config.sops.secrets."readarr/api_key".path}"
        "sonarr_api_key:${config.sops.secrets."sonarr/api_key".path}"
        "prowlarr_api_key:${config.sops.secrets."prowlarr/api_key".path}"

        "jellyfin_api_key:${config.sops.secrets."jellyfin/api_key".path}"
        "jellyseerr_api_key:${config.sops.secrets."jellyseerr/api_key".path}"

        "navidrome_salt:${config.sops.secrets."navidrome/salt".path}"
        "navidrome_token:${config.sops.secrets."navidrome/token".path}"

        "nextcloud_password:${config.sops.secrets."nextcloud/admin_password".path}"

        "paperless_api_key:${config.sops.secrets."paperless/api_key".path}"
        "photoprism_username:${config.sops.secrets."photoprism/admin_username".path}"
        "photoprism_password:${config.sops.secrets."photoprism/admin_password".path}"
      ];
    };
  };
}
