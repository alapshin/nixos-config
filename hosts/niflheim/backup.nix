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
      audiobooks = {
        paths = [
          "/mnt/data/audiobooks/"
        ];
      };
      photos = {
        paths = [
          "/mnt/data/photos/"
        ];
      };
    };

    passphraseFile = config.sops.secrets."borg/passphrase".path;
  };
}
