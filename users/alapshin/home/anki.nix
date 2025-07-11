{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    pkgs.anki
  ];
  programs.anki = {
    enable = false;
    style = "native";
    language = "en_US";
    sync = {
      autoSync = false;
      autoSyncMediaMinutes = 0;
    };
    addons = [
      pkgs.ankiAddons.review-heatmap
    ];
  };
}
