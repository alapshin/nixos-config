{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    audacity
    kodi
    mkvtoolnix
    mpv
    picard
    smplayer
  ];
}
