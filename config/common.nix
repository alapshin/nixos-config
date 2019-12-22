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

  console = {
    font = "latarcyrheb-sun32";
    earlySetup = true;
    useXkbConfig = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
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
