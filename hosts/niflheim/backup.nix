{ lib, config, ... }:

{
  sops.secrets = {
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
  };
}
