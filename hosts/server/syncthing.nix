{ config
, lib
, pkgs
, ...
}: {
  services.syncthing = {
    enable = true;
    overrideFolders = true;
    overrideDevices = true;

    settings = {
      devices = {
        carbon = {
          id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
        };
        server = {
          id = "S3PPR5V-TRLJQOD-FHSCUZZ-WYAEJ3B-ENRR5OM-IT7V6SD-LITNRFS-PU23XQK";
        };
      };
      folders = {
        "~/default" = {
          id = "syncthing";
          label = "Syncthing";
          type = "receiveencrypted";
        };
      };
    };
  };
}
