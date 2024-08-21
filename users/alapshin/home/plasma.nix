{ config, pkgs, ... }:
{
  programs.plasma = {
    enable = true;
    workspace.clickItemTo = "select";
    files = {
      "plasma-localerc"."Formats" = {
        "LANG" = config.home.language.base;
        "LC_TIME" = config.home.language.time;
        "LC_PAPER" = config.home.language.paper;
        "LC_NUMERIC" = config.home.language.numeric;
        "LC_MONETARY" = config.home.language.monetary;
        "LC_MEASUREMENT" = config.home.language.measurement;
      };
    };
  };
}
