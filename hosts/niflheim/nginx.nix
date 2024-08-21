{
  lib,
  pkgs,
  config,
  ...
}:
{
  users.users = {
    # Make acme certificates available to nginx user
    nginx.extraGroups = [ config.users.groups.acme.name ];
  };

  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        "_" = {
          default = true;
          forceSSL = true;
          useACMEHost = config.domain.base;
          locations = {
            "/" = {
              return = 404;
            };
          };
        };
      };
    };
  };
}
