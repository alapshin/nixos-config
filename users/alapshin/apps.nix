{ config, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  programs.kdeconnect.enable = true;
  programs.partition-manager.enable = true;

  users.users."${username}".packages = (with pkgs; [
    aspell
    aspellDicts.ru
    aspellDicts.en
    calibre
    colord-kde
    gimp
    handbrake
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    inkscape
    libreoffice-qt
    keepassxc
    mpv
    mkvtoolnix
    qbittorrent
    skrooge
    smplayer
    spotify
    tdesktop
    tor-browser-bundle-bin
    thunderbird
    ungoogled-chromium
  ]) ++ (with pkgs.plasma5Packages; [
    ark
    bismuth
    dolphin
    filelight
    gwenview
    kate
    kcolorchooser
    kwalletmanager
    okular
    spectacle
  ]);
}
