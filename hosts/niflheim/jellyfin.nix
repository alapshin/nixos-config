{ lib
, pkgs
, config
, domainName
, ...
}:
let
  port = 8096;
in
{
  services = {
    jellyfin = {
      enable = true;
    };

    nginx-ext.applications."jellyfin" = {
      auth = false;
      inherit port;
    };
  };
}
