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
        pkgs.hplip
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    atool
    bat
    bcache-tools
    borgbackup
    chromium
    exa
    fd
    file
    firefox
    gimp
    gnupg
    htop
    httpie
    imagemagick
    inkscape
    libreoffice-fresh
    keepassxc
    manpages
    mpv
    ncdu
    neovim
    nnn
    ntfs3g
    pandoc
    ripgrep
    rsync
    smartmontools
    smplayer
    tmux
    unzip
    wget 
    youtube-dl
  ];
}
