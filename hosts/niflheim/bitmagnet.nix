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
          flags = {
            delete_content_types = [
              "xxx"
              "software"
            ];
          };
        };
        postgres.user = cfg.user;
        http_server = {
          port = "3333";
        };
      };
    };
    webhost.applications."bitmagnet" = {
      auth = true;
      port = lib.strings.toInt config.services.bitmagnet.settings.http_server.port;
    };
  };
  systemd.services.bitmagnet.serviceConfig = {
    RestrictNetworkInterfaces = "lo wg0";
  };
}
