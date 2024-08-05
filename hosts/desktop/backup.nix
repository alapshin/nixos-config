{ lib, config, ... }:
{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
  };

  services.borgbackup.jobs = {
    default = {
      paths = [
        "/home/alapshin/books/"
        "/home/alapshin/Documents/"
      ];
    };
  };
}
