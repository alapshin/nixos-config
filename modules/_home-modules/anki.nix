# Anki flashcard software aspect
{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages =
    lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.anki
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
      pkgs.anki-bin
    ];
  programs.anki = {
    enable = false;
    style = "native";
    language = "en_US";
    profiles."User 1" = {
      sync = {
        autoSync = false;
        autoSyncMediaMinutes = 0;
      };
    };
    addons = [
      pkgs.ankiAddons.review-heatmap
    ];
  };
}
