{ config, ... }:

{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
  };

  services.backup = {
    enable = true;

    borg.jobs = {
      home = {
        paths = [
          "/home/alapshin/books/"
          "/home/alapshin/Documents/"
        ];
      };
    };

    passphraseFile = config.sops.secrets."borg/passphrase".path;
  };
}
