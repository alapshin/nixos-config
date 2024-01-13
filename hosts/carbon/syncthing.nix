{ config
, pkgs
, ...
}: let
  cfg = config.services.syncthing;

  username = "alapshin";
  usergroup = config.users.users.${username}.group;
in {
  sops = {
    secrets = {
      "syncthing/key" = {
        format = "binary";
        sopsFile = ./secrets/syncthing/key.pem;
      };
      "syncthing/cert" = {
        format = "binary";
        sopsFile = ./secrets/syncthing/cert.pem;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      bindfs
    ];
  };

  fileSystems = {
    "/home/${username}/Syncthing" = {
      fsType = "fuse.bindfs";
      device = "${cfg.dataDir}/${username}";
      options = [
        "nofail"
        "x-systemd.automount"
        "map=${cfg.user}/${username}:@${cfg.group}/@${usergroup}"
      ];
    };
  };

  services.syncthing = {
    enable = true;
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
    overrideFolders = true;
    overrideDevices = true;

    settings = {
      devices = {
        altdesk = {
          id = "K77LUC6-BZYZKY3-CHVAHJW-RXHUAPB-T6ZNZ6Q-KF77MQY-RCGE56Y-OV5XRAF";
        };
        carbon = {
          id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
        };
        desktop = {
          id = "SDAJAKH-WCN4BW6-H4H6QWF-43QC7DB-NWGL2RY-HOWYMNP-7TUWZZN-NC7MQAY";
        };
        pixel = {
          id = "QZYNABL-EZ5KIGC-NPZ76I7-7HBM3UR-RV2CEYL-7PUZ6CX-NFPH5V2-TIZU2A7";
        };
        server = {
          id = "S3PPR5V-TRLJQOD-FHSCUZZ-WYAEJ3B-ENRR5OM-IT7V6SD-LITNRFS-PU23XQK";
        };
      };
      folders = {
        "${cfg.dataDir}/seedvault" = {
          id = "seedvault";
          type = "receiveonly";
          label = "seedvault";
          devices = [ "carbon" "pixel" ];
        };
        "${cfg.dataDir}/${username}" = {
          id = "syncthing";
          label = "Syncthing";
          devices = [ "altdesk" "carbon" "desktop" "pixel" ];
        };
      };
    };
  };
}
