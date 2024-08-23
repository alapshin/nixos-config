{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "syncthing/key" = {
        format = "binary";
        sopsFile = ./secrets/syncthing/key.pem;
      };
      "syncthing/cert" = {
        format = "binary";
        sopsFile = ./secrets/syncthing/cert.pem;
      };
    };
  };

  services.syncthing = {
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;
  };
}
