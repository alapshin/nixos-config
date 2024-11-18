{
  lib,
  pkgs,
  config,
  ...
}:
{
  services = {
    changedetection-io = {
      enable = true;
      behindProxy = true;
    };
    # Workaround for https://github.com/dgtlmoon/changedetection.io/discussions/2259
    nginx.virtualHosts."cdio.${config.domain.base}" = {
      locations = {
        "/" = {
          extraConfig = ''
            proxy_set_header Referer "https://cdio.${config.domain.base}";
          '';
        };
      };
    };
    nginx-ext.applications."cdio" = {
      auth = true;
      port = config.services.changedetection-io.port;
    };
  };
}
