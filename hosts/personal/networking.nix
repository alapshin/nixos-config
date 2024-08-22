{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
