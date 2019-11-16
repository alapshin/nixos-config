{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kodi
    mkvtoolnix
    mpv
    smplayer
  ];
}
