{ lib
, pkgs
, config
, domainName
, ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
}
