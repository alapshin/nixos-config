{ config, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  programs.partition-manager.enable = true;

  users.users."${username}".packages = with pkgs; [
    aspell
    aspellDicts.ru
    aspellDicts.en
    calibre
    colord-kde
    digikam
    firefox
    gimp
    handbrake
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
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
    mkvtoolnix
    ntfs3g
    qbittorrent
    skrooge
    skypeforlinux
    smplayer
    spotify
    tdesktop
    torbrowser
    thunderbird
    ungoogled-chromium
  ];
}
