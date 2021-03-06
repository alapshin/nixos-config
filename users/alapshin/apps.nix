{ config, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  users.users."${username}".packages = with pkgs; [
    calibre
    chromium
    colord-kde
    firefox
    gimp
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US-large
    inkscape
    libreoffice-fresh
    ark
    dolphin
    filelight
    gwenview
    kate
    kcolorchooser
    kdeconnect
    kwalletmanager
    okular
    spectacle
    keepassxc
    mpv
    ntfs3g
    partition-manager
    qbittorrent
    skrooge
    skypeforlinux
    smplayer
    thunderbird
  ];
}
