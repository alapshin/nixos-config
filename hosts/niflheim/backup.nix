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
      books = {
        paths = [
          "/mnt/data/books/"
        ];
      };
    };

    passphraseFile = config.sops.secrets."borg/passphrase".path;
  };
}
