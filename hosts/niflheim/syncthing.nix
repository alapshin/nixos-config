{ lib
, pkgs
, config
, ...
}: {

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

  services = {
    syncthing = {
      enable = true;
      overrideFolders = true;
      overrideDevices = true;
      key = config.sops.secrets."syncthing/key".path;
      cert = config.sops.secrets."syncthing/cert".path;

      settings = {
        gui.insecureSkipHostcheck = true;

        devices = {
          pixel = {
            id = "QZYNABL-EZ5KIGC-NPZ76I7-7HBM3UR-RV2CEYL-7PUZ6CX-NFPH5V2-TIZU2A7";
          };
          carbon = {
            id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
          };
        };

        folders = {
          "~/default" = {
            id = "syncthing";
            label = "Syncthing";
            type = "receiveonly";
          };
        };
      };
    };

    nginx-ext.applications."syncthing" = {
      auth = true;
      port = 8384;
    };
  };
}
