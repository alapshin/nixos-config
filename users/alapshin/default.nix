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
    ledger2beancount
  ];

  blockchainPackages = with pkgs; [
    feather
    electrum
  ];

  dictionaries = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.ru
    aspellDicts.sr
    hunspell
    hunspellDicts.en-us
    hunspellDicts.ru-ru
    customHunspellDicts.sr
  ];

  guiDevTools = with pkgs; [
    drawio
  ];

  javaPackages = with pkgs; [
    gradle
    groovy
    scrcpy
    android-udev-rules
    jetbrains.idea-ultimate
    # androidStudioPackages.stable
    android-studio-stable-with-sdk
  ];

  kdePackages = with pkgs.kdePackages; [
    ark
    dolphin
    filelight
    gwenview
    kate
    kcolorchooser
    okular
    spectacle
  ];

  pythonPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        autobean
        beancount3
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
  imports = [
    (import ./home (
      args
      // {
        inherit username;
        isNixOS = true;
      }
    ))
  ];

  programs = {
    adb.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-composite-blur
        obs-move-transition
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

    zsh.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = false;
  };

  users.users."${username}" = {
    uid = 1000;
    shell = pkgs.zsh;
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
        anki
        audacity
        calibre
        colord-kde
        element-desktop
        freetube
        gimp
        inkscape
        jellyfin-media-player
        keepassxc
        kid3-qt
        kleopatra
        krename
        libreoffice-qt6-fresh
        logseq
        qbittorrent
        sddm-kcm
        smplayer
        strawberry
        telegram-desktop
        tor-browser
      ]
      ++ accountingTools
      ++ blockchainPackages
      ++ dictionaries
      ++ guiDevTools
      ++ javaPackages
      ++ kdePackages
      ++ pythonPackages;
  };
}
