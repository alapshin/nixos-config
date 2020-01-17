# Settings that don't fit into particular category

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    atool
    audacity
    awscli
    bat
    bcache-tools
    borgbackup
    calibre
    chromium
    colord-kde
    exa
    fd
    file
    firefox
    gdrive
    gimp
    git
    gnupg
    htop
    httpie
    hunspell
    #hunspellDicts.ru_RU
    hunspellDicts.en_US-large
    imagemagick
    inkscape
    jq
    libreoffice-fresh
    kdeconnect
    kdeApplications.ark
    kdeApplications.dolphin
    kdeApplications.filelight
    kdeApplications.gwenview
    kdeApplications.kwalletmanager
    kdeApplications.okular
    kdeApplications.spectacle
    keepassxc
    ktorrent
    manpages
    mkvtoolnix
    mpv
    moreutils
    ncdu
    neovim
    nnn
    ntfs3g
    p7zip
    pandoc
    partition-manager
    picard
    plasma-browser-integration 
    ripgrep
    rsync
    skrooge
    slack
    smplayer
    skype
    smartmontools
    tdesktop
    thunderbird
    tmux
    tree
    unrar
    unzip
    usbutils
    wget 
    youtube-dl
  ];
}
