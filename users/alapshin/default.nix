{
  config,
  lib,
  myutils,
  pkgs,
  ...
}: let
  username = "alapshin";

  gitPackages = with pkgs; [
    gh
    git
    gitui
    git-crypt
    git-extras
    git-filter-repo
    git-lfs
    tig
    transcrypt
  ];

  javaPackages = with pkgs; [
    async-profiler

    groovy
    scrcpy
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
    kcolorchooser
    kwalletmanager
    okular
    spectacle
  ];

  pythonPackages = pkgs.python3.withPackages (
    pythonPackages:
      with pythonPackages; [
        ipython
        notebook
        matplotlib
        numpy
        pandas
        # pelican
        scikitlearn
        seaborn
      ]
  );
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
        oneplus = {
          id = "BUNDEAI-JNT4FBK-KL444PA-XY3YVQA-YSMS7BB-N2NAWRE-6DAXRRQ-WWRAUQK";
        };
      };
      folders = {
        "/home/${username}/Syncthing" = {
          id = "syncthing";
          label = "Syncthing";
          devices = ["altdesk" "carbon" "desktop" "oneplus"];
        };
      };
      overrideFolders = true;
      overrideDevices = false;
    };
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
      "wheel"
    ];

    packages = with pkgs;
      [
        aspell
        aspellDicts.en
        aspellDicts.ru
        atool
        bat
        bcache-tools
        borgbackup
        calibre
        colord-kde
        digikam
        electrum
        exa
        fd
        file
        gimp
        gnupg
        handbrake
        htop
        http-prompt
        httpie
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
        nnn
        openssl
        p7zip
        pandoc
        pciutils
        qbittorrent
        ripgrep
        rsync
        shellcheck
        s-tui
        skrooge
        smartmontools
        smplayer
        spotify
        stress-ng
        tdesktop
        thunderbird
        tor-browser-bundle-bin
        tree
        ungoogled-chromium
        unrar
        unzip
        usbutils
        wget
        youtube-dl
        yt-dlp
      ]
      ++ gitPackages
      ++ javaPackages
      ++ plasmaPackages;
  };
}
