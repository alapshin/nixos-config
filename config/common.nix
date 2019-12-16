{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
    ];
    enableDefaultFonts = false;
  };

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

  time = {
    timeZone = "Europe/Moscow";
    hardwareClockInLocalTime = true;
  };

  security.sudo = {
    extraConfig = ''
      Defaults !tty_tickets
    '';
  };
}
