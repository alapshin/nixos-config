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
        pkgs.hplipWithPlugin_3_16_11
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    atool
    awscli
    bat
    bcache-tools
    birdtray
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
    imagemagick
    inkscape
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
    unzip
    wget 
    usbutils
    youtube-dl
  ];
}
