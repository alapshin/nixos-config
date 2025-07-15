{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs = {
    adb.enable = true;

    java = {
      enable = true;
      package = pkgs.jdk21;
    };

    zsh.enable = true;
    fish.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };
}
