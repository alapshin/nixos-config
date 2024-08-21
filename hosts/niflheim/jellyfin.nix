{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 8096;
in
{
  sops = {
    secrets = {
      "jellyfin/api_key" = { };
      "jellyseerr/api_key" = { };
    };
  };
  services = {
    jellyfin = {
      enable = true;
    };

    jellyseerr.enable = true;

    nginx.virtualHosts = {
      "jellyfin.${config.domain.base}" = {
        locations = {
          "/socket" = {
            proxyWebsockets = true;
          };
        };
      };
    };

    nginx-ext.applications = {
      "jellyfin" = {
        auth = false;
        inherit port;
      };
      "jellyseerr" = {
        auth = false;
        port = config.services.jellyseerr.port;
      };
    };
  };
}
