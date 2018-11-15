{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    atool
    borgbackup
    chromium
    firefox
    gimp
    htop
    inkscape
    libreoffice-fresh
    keepassxc
    manpages
    mpv
    neovim
    nix-index
    smplayer
    steam
    unzip
    wget 
    wineStaging
    youtube-dl
  ];
}
