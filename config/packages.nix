{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    atool
    borgbackup
    chromium
    firefox
    gimp
    git
    htop
    inkscape
    libreoffice-fresh
    keepassxc
    manpages
    mpv
    neovim
    smplayer
    steam
    tig
    wget 
    wineStaging
    youtube-dl
  ];
}
