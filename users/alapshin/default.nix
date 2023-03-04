{
  config,
  lib,
  pkgs,
  ...
}: let
  username = "alapshin";

  borgPackages = with pkgs; [
    vorta
    borgbackup
    borgmatic
  ];

  blockchainPackages = with pkgs; [
    electrum
    bisq-desktop
    monero-cli
    monero-gui
  ];


  devTools = with pkgs; [
    age
    hadolint
    shellcheck
    sops
    ssh-to-age
  ];

  guiDevTools = with pkgs; [
    drawio
    pencil
    insomnia
  ];

  gitPackages = with pkgs; [
    git
    git-crypt
    git-extras
    git-filter-repo
    git-lfs
    tig
    transcrypt
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

  unityPackages = with pkgs; [
    unityhub
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
    (python3.withPackages (ps:
      with ps; [
        ipython
        notebook
        matplotlib
        numpy
        pandas
        scikit-learn
        seaborn
      ]))
  ];
  texlivePackages = lib.toList pkgs.texlive.combined.scheme-full;

in {
  imports = [
    ./home
  ];

  programs.adb.enable = true;
  programs.java.enable = true;
  programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;
  programs.kdeconnect.enable = true;
  programs.partition-manager.enable = true;

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
      "wheel"
    ];

    packages = with pkgs;
      [
        anki-bin
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
        fd
        ffmpeg
        file
        gimp
        gnupg
        handbrake
        htop
        hunspell
        hunspellDicts.en_US
        hunspellDicts.ru_RU
        imagemagick
        inkscape
        jq
        keepassxc
        libreoffice-qt
        lm_sensors
        man-pages
        mkvtoolnix
        moreutils
        mpv
        ncdu
        obs-studio
        openssl
        p7zip
        pciutils
        qbittorrent
        ripgrep
        rsync
        s-tui
        skrooge
        smartmontools
        smplayer
        spicetify-cli
        spotify
        stress-ng
        tdesktop
        tor-browser-bundle-bin
        tree
        ungoogled-chromium
        unrar
        unzip
        usbutils
        wget
        wireguard-tools
        xclip
        zoom-us
      ]
      ++ blockchainPackages
      ++ devTools
      ++ gitPackages
      ++ guiDevTools
      ++ borgPackages
      ++ javaPackages
      ++ unityPackages
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

    syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
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
          devices = ["altdesk" "carbon" "desktop" "pixel"];
        };
      };
      overrideFolders = true;
      overrideDevices = false;
    };
  };
}
