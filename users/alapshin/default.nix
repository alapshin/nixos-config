{
  lib,
  pkgs,
  config,
  ...
}@args:
let
  username = builtins.baseNameOf ./.;

  accountingTools = with pkgs; [
    fava
    beanprice
  ];

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

  kdePackages = with pkgs.kdePackages; [
    ark
    dolphin
    filelight
    gwenview
    kate
    kcolorchooser
    kleopatra
    spectacle
  ];

  pythonPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        autobean
        beancount
        beanquery
        ipython
        notebook
        matplotlib
        numpy
        pandas
        scikit-learn
        seaborn
      ]
    ))
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
        # audacity
        calibre
        gimp3
        inkscape
        kid3-qt
        libreoffice-qt6-fresh
        qbittorrent
        smplayer
        telegram-desktop
        tor-browser
      ]
      ++ accountingTools
      ++ blockchainPackages
      ++ dictionaries
      ++ kdePackages
      ++ pythonPackages;
  };
}
