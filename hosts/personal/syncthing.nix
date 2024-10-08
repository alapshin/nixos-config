{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.syncthing;

  username = "alapshin";
  usergroup = config.users.users.${username}.group;
  bindFsMountOptions = [
    "nofail"
    "x-systemd.automount"
    "map=${cfg.user}/${username}:@${cfg.group}/@${usergroup}"
  ];
in
{
  environment = {
    systemPackages = with pkgs; [ bindfs ];
  };

  fileSystems = {
    "/home/${username}/books" = {
      fsType = "fuse.bindfs";
      device = "${cfg.dataDir}/${username}/books";
      options = bindFsMountOptions;
    };
    "/home/${username}/calibre" = {
      fsType = "fuse.bindfs";
      device = "${cfg.dataDir}/${username}/calibre";
      options = bindFsMountOptions;
    };
    "/home/${username}/Documents" = {
      fsType = "fuse.bindfs";
      device = "${cfg.dataDir}/${username}/documents";
      options = bindFsMountOptions;
    };
    "/home/${username}/Syncthing" = {
      fsType = "fuse.bindfs";
      device = "${cfg.dataDir}/${username}/syncthing";
      options = bindFsMountOptions;
    };
  };

  systemd.tmpfiles.settings = {
    "10-syncthing" = {
      "${cfg.dataDir}/${username}/seedvault" = {
        d = {
          user = cfg.user;
          group = cfg.group;
        };
      };
      "${cfg.dataDir}/${username}/books" = {
        d = {
          user = cfg.user;
          group = cfg.group;
        };
      };
      "${cfg.dataDir}/${username}/calibre" = {
        d = {
          user = cfg.user;
          group = cfg.group;
        };
      };
      "${cfg.dataDir}/${username}/documents" = {
        d = {
          user = cfg.user;
          group = cfg.group;
        };
      };
      "${cfg.dataDir}/${username}/syncthing" = {
        d = {
          user = cfg.user;
          group = cfg.group;
        };
      };
    };
  };

  services.syncthing = {
    enable = lib.mkDefault true;
    overrideFolders = lib.mkDefault true;
    overrideDevices = lib.mkDefault true;

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
      };
      folders = {
        "${cfg.dataDir}/seedvault" = {
          id = "seedvault";
          type = "receiveonly";
          label = "SeedVault";
          devices = [
            "carbon"
            "desktop"
            "pixel"
          ];
        };
        "${cfg.dataDir}/${username}/books" = {
          id = "books";
          label = "Books";
          devices = [
            "carbon"
            "desktop"
          ];
        };
        "${cfg.dataDir}/${username}/calibre" = {
          id = "calibre";
          label = "Calibre";
          devices = [
            "carbon"
            "desktop"
          ];
        };
        "${cfg.dataDir}/${username}/documents" = {
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
        "${cfg.dataDir}/${username}/syncthing" = {
          id = "syncthing";
          label = "Syncthing";
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
      };
    };
  };
}
