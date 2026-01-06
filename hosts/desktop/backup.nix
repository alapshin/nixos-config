{ config, ... }:

{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
  };

  services.backup = {
    enable = true;

    jobs = {
      home = {
        paths = [
          "/home/alapshin/books"
          "/home/alapshin/Documents"
        ];
      };
    };

    passphraseFile = config.sops.secrets."borg/passphrase".path;
  };
}
