{ lib
, pkgs
, config
, domainName
, ...
}: {
  sops = {
    secrets = {
      "photoprism/admin_username" = { };
      "photoprism/admin_password" = { };
    };
  };
  services = {
    photoprism = {
      enable = true;
      originalsPath = "/mnt/data/photos";
      passwordFile = config.sops.secrets."photoprism/admin_password".path;
    };

    nginx.virtualHosts = {
      "photoprism.${domainName}" = {
        locations."/" = {
          proxyWebsockets = true;
        };
      };
    };

    nginx-ext.applications."photoprism" = {
      auth = false;
      port = config.services.photoprism.port;
    };
  };

  systemd.tmpfiles.settings = {
    "10-photoprism" = {
      "/mnt/data/photos" = {
        d = {
          mode = "0755";
        };
      };
    };
  };
}
