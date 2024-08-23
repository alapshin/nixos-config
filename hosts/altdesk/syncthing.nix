{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.syncthing = {
    enable = false;
  };
}
