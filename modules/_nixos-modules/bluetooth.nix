# Bluetooth hardware support aspect
{
  lib,
  pkgs,
  config,
  ...
}:
{
  hardware = {
    bluetooth = {
      enable = true;
    };
  };
}
