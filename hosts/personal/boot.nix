{
  lib,
  pkgs,
  config,
  ...
}:

{
  boot = {
    loader = {
      timeout = 15;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = lib.mkDefault true;
        consoleMode = "max";
        configurationLimit = 10;
      };
    };
  };
}
