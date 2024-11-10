{ lib, config, ... }:
let
  cfg = config.services.bitmagnet;
in
{
  services = {
    bitmagnet = {
      enable = true;
      useLocalPostgresDB = true;
      settings = {
        classifier = {
          delete_xxx = true;
        };
        postgres.user = cfg.user;
        http_server = {
          port = "3333";
        };
      };
    };
    nginx-ext.applications."bitmagnet" = {
      auth = true;
      port = lib.strings.toInt config.services.bitmagnet.settings.http_server.port;
    };
  };
  systemd.services.bitmagnet.serviceConfig = {
    RestrictNetworkInterfaces = "lo wg0";
  };
}
