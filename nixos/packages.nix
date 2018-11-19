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
    nix-index
    ntfs3g
    smplayer
    steam
    unzip
    wget 
    wineStaging
    youtube-dl
  ];
}
