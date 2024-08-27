{ config, ... }:

{
  sops.secrets = {
    "borg/borg_ed25519" = {
      mode = "0600";
      format = "binary";
      sopsFile = ./secrets/borg/borg_ed25519;
    };
    "borg/borg_ed25519.pub" = {
      mode = "0600";
      format = "binary";
      sopsFile = ./secrets/borg/borg_ed25519.pub;
    };
  };

  services.backup = {
    user = "u399502";
    host = "u399502.your-storagebox.de";
    port = 23;

    sshKeyFile = config.sops.secrets."borg/borg_ed25519".path;
  };
}
