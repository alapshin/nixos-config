{ lib, config, ... }:
{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = lib.mkForce ./secrets/borg/passphrase.yaml;
    };
  };
  services.borgbackup.jobs = {
    default = {
      paths = [
        "/home/alapshin/books"
        "/home/alapshin/Documents"
      ];
    };
  };
}
