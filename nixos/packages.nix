{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    atool
    borgbackup
    chromium
    file
    firefox
    gimp
    gnupg
    htop
    inkscape
    libreoffice-fresh
    keepassxc
    manpages
    mpv
    neovim
    ntfs3g
    smplayer
    unzip
    wget 
    youtube-dl
  ];
}
