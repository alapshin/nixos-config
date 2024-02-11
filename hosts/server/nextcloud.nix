{ lib
, pkgs
, config
, domainName
, ...
}:
let
  nextcloudHostname = "nextcloud.${domainName}";
in
{
  sops = {
    secrets = {
      "nextcloud/password" = {
        owner = config.users.users.nextcloud.name;
      };
    };
  };

  users.users = {
    # Make sops keys available to nextcloud user
    nextcloud.extraGroups = [
      config.users.groups.keys.name
    ];
  };

  services = {
    nginx = {
      virtualHosts = {
        ${nextcloudHostname} = {
          forceSSL = true;
          useACMEHost = domainName;
        };
      };
    };

    imaginary = {
      enable = true;
      settings.return-size = true;
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      https = true;
      hostName = nextcloudHostname;

      caching.redis = true;
      configureRedis = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/password".path;
      };
      database.createLocally = true;

      settings = {
        # Memories options
        memories = {
          exiftool = "${pkgs.exiftool}/bin/exiftool";
          exiftool_no_local = true;
          vod = {
            ffmpeg = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
            ffprobe = "${pkgs.jellyfin-ffmpeg}/bin/ffprobe";
          };
        };
        enabledPreviewProviders = [
          "OC\\Preview\\Movie"
          "OC\\Preview\\Imaginary"
        ];
        preview_imaginary_url = "http://${config.services.imaginary.address}:${toString config.services.imaginary.port}";
      };

      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit bookmarks calendar contacts gpoddersync memories previewgenerator tasks;
      } // {
        recognize = pkgs.fetchNextcloudApp {
          license = "agpl3";
          url = "https://github.com/nextcloud/recognize/releases/download/v6.0.1/recognize-6.0.1.tar.gz";
          sha256 = "sha256-7LuXBz7nrimRRUowu47hADzD5XhVyZP4Z39om8IRAZw=";
        };
      };
      extraAppsEnable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Memories app
    perl
    exiftool
    jellyfin-ffmpeg
    # Recognize app
    nodejs
  ];
  systemd.services.nextcloud-cron = {
    path = [ pkgs.perl pkgs.exiftool ];
  };
  systemd.services.nextcloud-setup = {
    path = [ pkgs.perl pkgs.exiftool ];
  };
  systemd.services.phpfpm-nextcloud = {
    path = [ pkgs.perl pkgs.exiftool ];
  };
}
