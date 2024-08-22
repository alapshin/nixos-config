{
  lib,
  pkgs,
  config,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot = {
        # Lanzaboote currently replaces the systemd-boot module.
        # This setting is usually set to true in configuration.nix
        # generated at installation time. So we force it to false
        # for now.
        enable = false;
      };
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
