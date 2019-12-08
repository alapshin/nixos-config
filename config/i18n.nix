{ config, pkgs, ... }:

{
  i18n = {
    consoleFont = "latarcyrheb-sun32";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };
}
