{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      noto-fonts
    ];
    fontconfig = {
      ultimate.enable = true;
    };
  };
}
