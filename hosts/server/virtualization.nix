{
  lib,
  pkgs,
  config,
  ...
}:
{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
  };
}
