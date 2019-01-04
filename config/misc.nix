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
    pandoc
    picard
    ripgrep
    rsync
    smartmontools
    smplayer
    tdesktop
    tmux
    unzip
    wget 
    usbutils
    youtube-dl
  ];
}
