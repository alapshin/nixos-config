{
  lib,
  pkgs,
  config,
  ...
}:
let
  onlyofficeHostname = "onlyoffice.${config.domain.base}";
in
{
  sops = {
    secrets = {
      "onlyoffice/jwt_secret" = {
        owner = "onlyoffice";
      };
    };
  };
  services = {
    onlyoffice = {
      enable = true;
      port = 11111;
      hostname = onlyofficeHostname;
      jwtSecretFile = config.sops.secrets."onlyoffice/jwt_secret".path;
    };
    nginx.virtualHosts."${onlyofficeHostname}" = {
      forceSSL = true;
      useACMEHost = config.domain.base;
    };
  };
}
