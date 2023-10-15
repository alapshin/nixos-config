{ config
, lib
, pkgs
, ...
} @ args:
let
  username = builtins.baseNameOf ./.;

  accountingTools = with pkgs; [
    fava
    gnucash
    ledger2beancount
    beancount-black
  ];

  borgPackages = with pkgs; [
    vorta
    borgbackup
    borgmatic
  ];

  blockchainPackages = with pkgs; [
    electrum
    monero-cli
    monero-gui
  ];

  devTools = with pkgs; [
    age
    sops
    ssh-to-age
  ];

  guiDevTools = with pkgs; [
    drawio
    insomnia
    jetbrains-toolbox
  ];

  luaPackages = with pkgs; [
    stylua
  ];

  javaPackages = with pkgs; [
    async-profiler

    gradle
    groovy
    scrcpy
    # Install android-fhs-env package used as devShell for android
    android-fhs-env
    android-udev-rules
    jetbrains.idea-ultimate
    androidStudioPackages.stable
    androidStudioPackages.beta
    androidStudioPackages.canary
  ];

  plasmaPackages = with pkgs.plasma5Packages; [
    ark
    bismuth
    dolphin
    filelight
    gwenview
    kate
    kamoso
    kasts
    kcolorchooser
    kwalletmanager
    okular
    spectacle
  ];

  pythonPackages = with pkgs; [
    (
      python3.withPackages (ps:
        with ps; [
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
  texlivePackages = lib.toList pkgs.texlive.combined.scheme-full;
in
{
  imports = [
    (import ./home (args // { inherit username; }))
  ];

  programs = {
    adb.enable = true;
    java.enable = true;
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
        aspell
        aspellDicts.en
        aspellDicts.ru
        atool
        bcache-tools
        birdtray
        calibre
        colord-kde
        digikam
        element-desktop
        exiftool
        ffmpeg
        file
        freetube
        gimp
        gnupg
        htop
        hunspell
        hunspellDicts.en_US
        hunspellDicts.ru_RU
        imagemagick
        inkscape
        jq
        keepassxc
        kleopatra
        libreoffice-qt
        lm_sensors
        logseq
        man-pages
        moreutils
        mpv
        openssl
        p7zip
        pciutils
        qbittorrent
        rsync
        s-tui
        smartmontools
        smplayer
        stress-ng
        telegram-desktop
        tor-browser-bundle-bin
        tree
        ungoogled-chromium
        unrar
        unzip
        usbutils
        wget
        wireguard-tools
        xclip
      ]
      ++ accountingTools
      ++ blockchainPackages
      ++ devTools
      ++ guiDevTools
      ++ borgPackages
      ++ luaPackages
      ++ javaPackages
      ++ plasmaPackages
      ++ pythonPackages
      ++ texlivePackages;
  };

  services = {
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };

    peroxide = {
      enable = true;
    };

    syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
      settings = {
        devices = {
          altdesk = {
            id = "K77LUC6-BZYZKY3-CHVAHJW-RXHUAPB-T6ZNZ6Q-KF77MQY-RCGE56Y-OV5XRAF";
          };
          carbon = {
            id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
          };
          desktop = {
            id = "SDAJAKH-WCN4BW6-H4H6QWF-43QC7DB-NWGL2RY-HOWYMNP-7TUWZZN-NC7MQAY";
          };
          pixel = {
            id = "QZYNABL-EZ5KIGC-NPZ76I7-7HBM3UR-RV2CEYL-7PUZ6CX-NFPH5V2-TIZU2A7";
          };
        };
        folders = {
          "/home/${username}/Syncthing" = {
            id = "syncthing";
            label = "Syncthing";
            devices = [ "altdesk" "carbon" "desktop" "pixel" ];
          };
        };
      };
      overrideFolders = true;
      overrideDevices = false;
    };
  };
}
