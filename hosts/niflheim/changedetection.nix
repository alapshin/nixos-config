{ lib
, pkgs
, config
, ...
}: {
  services = {
    changedetection-io = {
      enable = true;
      behindProxy = true;
    };
    nginx-ext.applications."cdio" = {
      auth = true;
      port = config.services.changedetection-io.port;
    };
  };
}
