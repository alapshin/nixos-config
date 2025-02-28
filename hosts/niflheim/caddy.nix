{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.caddy = {
    enable = true;
  };
}
