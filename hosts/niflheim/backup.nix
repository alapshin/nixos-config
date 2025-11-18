{ config, ... }:

{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
  };

  services.backup = {
    enable = true;
    passphraseFile = config.sops.secrets."borg/passphrase".path;
  };
}
