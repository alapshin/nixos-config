{ ... }:
{
  flake.modules.nixos.niflheim-backup =
    { config, ... }:
    {
      sops.secrets = {
        "borg/passphrase" = {
          sopsFile = ../../hosts/_hosts/niflheim/secrets/borg/passphrase.yaml;
        };
      };

      services.backup = {
        enable = true;
        passphraseFile = config.sops.secrets."borg/passphrase".path;
      };
    };
}
