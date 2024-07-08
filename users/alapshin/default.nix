{ config
, lib
, pkgs
, ...
} @ args:
let
  username = builtins.baseNameOf ./.;

  accountingTools = with pkgs; [
    # fava
    ledger2beancount
  ];

  borgPackages = with pkgs; [
    vorta
    borgbackup
    borgmatic
  ];

  blockchainPackages = with pkgs; [
    feather
    # electrum
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
    insomnia
  ];

  javaPackages = with pkgs; [
    gradle
    groovy
    scrcpy
    # Install android-fhs-env package used as devShell for android
    android-fhs-env
    android-udev-rules
    # jetbrains.idea-ultimate
    androidStudioPackages.stable
    androidStudioPackages.beta
    androidStudioPackages.canary
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
    (
      python3.withPackages (ps:
        with ps; [
          autobean
          beancount
          beanprice
          ipython
          notebook
          matplotlib
          numpy
          pandas
          scikit-learn
          seaborn
        ])
    )
  ];
in
{
  imports = [
    (import ./home (args // { inherit username; isNixOS = true; }))
  ];

  programs = {
    adb.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    zsh.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  users.users."${username}" = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Andrei Lapshin";
    initialPassword = "12345678";
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

    packages = with pkgs;
      [
        anki
        calibre
        colord-kde
        digikam
        element-desktop
        freetube
        gimp
        inkscape
        keepassxc
        kid3-qt
        kleopatra
        krename
        libreoffice-qt
        logseq
        qbittorrent
        sddm-kcm
        smplayer
        strawberry
        subtitlecomposer
        telegram-desktop
        tor-browser-bundle-bin
        ungoogled-chromium
      ]
      ++ accountingTools
      ++ blockchainPackages
      ++ dictionaries
      ++ guiDevTools
      ++ borgPackages
      ++ javaPackages
      ++ kdePackages
      ++ pythonPackages;
  };
}
