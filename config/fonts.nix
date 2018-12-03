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
}
