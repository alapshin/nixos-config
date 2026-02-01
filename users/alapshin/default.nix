{
  lib,
  pkgs,
  config,
  ...
}@args:
let
  username = builtins.baseNameOf ./.;

  blockchainPackages = with pkgs; [
    feather
    electrum
  ];

  dictionaries = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.es
    aspellDicts.ru
    aspellDicts.sr
    hunspell
    hunspellDicts.en-us
    hunspellDicts.es-es
    hunspellDicts.ru-ru
    customHunspellDicts.sr
  ];
in
{
  users.users."${username}" = {
    uid = 1000;
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Andrei Lapshin";
    extraGroups = [
      "adbusers"
      "audio"
      "docker"
      "input"
      "jackaudio"
      "libvirtd"
      "networkmanager"
      "syncthing"
      "tss"
      "wheel"
    ];

    packages =
      with pkgs;
      [
        audacity
        calibre
        gimp
        inkscape
        kid3-qt
        libreoffice-qt-fresh
        qbittorrent
        smplayer
        tor-browser
      ]
      ++ blockchainPackages
      ++ dictionaries
      ++ (with pkgs.kdePackages; [
        ark
        dolphin
        filelight
        gwenview
        kate
        kcolorchooser
        kleopatra
        spectacle
      ]);
  };
}
