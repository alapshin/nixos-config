{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
