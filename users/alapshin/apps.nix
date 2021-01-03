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
    kdeApplications.ark
    kdeApplications.dolphin
    kdeApplications.filelight
    kdeApplications.gwenview
    kdeApplications.kate
    kdeApplications.kcolorchooser
    kdeApplications.kdeconnect-kde
    kdeApplications.kwalletmanager
    kdeApplications.okular
    kdeApplications.spectacle
    keepassxc
    mpv
    ntfs3g
    partition-manager
    qbittorrent
    skrooge
    smplayer
    thunderbird
  ];
}
