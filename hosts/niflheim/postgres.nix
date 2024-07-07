{ lib
, pkgs
, config
, ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
}
