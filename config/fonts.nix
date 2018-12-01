{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      liberation_ttf
    ];
    enableDefaultFonts = false;
  };
}
