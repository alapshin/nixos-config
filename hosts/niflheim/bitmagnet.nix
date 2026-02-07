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
          local_address = "127.0.0.1:3333";
        };
      };
    };
    vpn.applications."bitmagnet" = {
      user = config.services.bitmagnet.user;
    };
    webhost.applications."bitmagnet" = {
      auth = true;
      port = lib.strings.toInt config.services.bitmagnet.settings.http_server.port;
    };
  };
}
