{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "DejaVu Sans Mono" ];
      };
    };
  };
}
