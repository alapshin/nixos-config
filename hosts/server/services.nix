{ lib
, pkgs
, config
, ...
}:
{
  users.users = {
    # Make acme certificates available to nginx user
    nginx.extraGroups = [
      config.users.groups.acme.name
    ];
  };

  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      recommendedProxySettings = true;
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
    };
  };
}
