# Settings that don't fit into particular category

{ config, pkgs, ... }:

{
  services = {
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };
    # Enable CUPS
    printing = {
      enable = true;
      drivers = [
        pkgs.hplipWithPlugin
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    atool
    awscli
    bat
    bcache-tools
    borgbackup
    chromium
    exa
    fd
    file
    firefox
    gdrive
    gimp
    gnupg
    hplipWithPlugin
    htop
    httpie
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US-large
    imagemagick
    inkscape
    jq
    libreoffice-fresh
    keepassxc
    manpages
    mkvtoolnix
    mpv
    ncdu
    neovim
    nnn
    ntfs3g
    p7zip
    pandoc
    picard
    ripgrep
    rsync
    slack
    smartmontools
    smplayer
    tdesktop
    tmux
    tree
    unrar
    unzip
    usbutils
    wget 
    youtube-dl
  ];
}
