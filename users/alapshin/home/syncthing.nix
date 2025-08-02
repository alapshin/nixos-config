{
  lib,
  config,
  osConfig,
  ...
}:
let
  hostname = osConfig.networking.hostName;
in
{
  sops = {
    secrets = {
      "syncthing/key" = {
        format = "binary";
        sopsFile = ../secrets/syncthing/${hostname}-key.pem;
      };
      "syncthing/cert" = {
        format = "binary";
        sopsFile = ../secrets/syncthing/${hostname}-cert.pem;
      };
    };
  };

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    extraOptions = [
      # Don't create default ~/Sync folder
      "--no-default-folder"
    ];
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    settings = {
      devices = {
        altdesk = {
          id = "3GUZANY-DAA5HR6-T77OYPT-I6P2YV6-TXVCCXI-GVYRW66-3PUCCXF-IMKTLQQ";
        };
        carbon = {
          id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
        };
        desktop = {
          id = "SDAJAKH-WCN4BW6-H4H6QWF-43QC7DB-NWGL2RY-HOWYMNP-7TUWZZN-NC7MQAY";
        };
        ebook = {
          id = "P75SKEA-ZPCPQIA-MK6VO4H-LQDUX37-AVCLACA-HZGOCHN-3KI24LT-Q3CKNQ3";
        };
        pixel = {
          id = "QZYNABL-EZ5KIGC-NPZ76I7-7HBM3UR-RV2CEYL-7PUZ6CX-NFPH5V2-TIZU2A7";
        };
        macbook = {
          id = "KN6REOP-YQVDXWY-Z454FBH-FHWDYVD-PTKPRYD-PIKTXF4-PMYIVSX-P27TRQD";
        };
        pixel-work = {
          id = "ZKOGFAS-ED6GZAB-5QYUMXK-APQSBQI-TB72HLX-HKWOHOU-EXWQ2OS-EVCZJAC";
        };
      };
      folders = {
        "~/books" = {
          id = "books";
          label = "Books";
          devices = [
            "carbon"
            "desktop"
          ];
        };
        "~/calibre" = {
          id = "calibre";
          label = "Calibre";
          devices = [
            "carbon"
            "desktop"
          ];
        };
        "~/Documents" = {
          id = "documents";
          label = "Documents";
          devices = [
            "carbon"
            "desktop"
            "pixel"
          ];
          versioning = {
            type = "simple";
            params = {
              keep = "7";
            };
          };
        };
        "~/Syncthing" = {
          id = "syncthing";
          label = "Syncthing";
          devices = [
            "carbon"
            "desktop"
            "ebook"
            "pixel"
          ];
          versioning = {
            type = "simple";
            params = {
              keep = "7";
            };
          };
        };
        "~/worksync" = {
          id = "worksync";
          label = "Work Syncthing";
          devices = [
            "desktop"
            "pixel-work"
          ];
          versioning = {
            type = "simple";
            params = {
              keep = "7";
            };
          };
        };
      };
    };
  };

  systemd.user.services.syncthing.unitConfig.After = [ "sops-nix.service" ];
  systemd.user.services.syncthing-init.unitConfig.After = [ "sops-nix.service" ];
}
