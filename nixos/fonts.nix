{ config, pkgs, ... }:

{
  fonts = {
    fonts = with pkgs; [
      noto-fonts
    ];
  };
}
