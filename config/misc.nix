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
    redshift = {
      enable = true;
      provider = "manual";
      latitude = "58.5969";
      longitude = "49.6583";
      extraOptions = [ "-P" "-m randr" ];
    };
    # Enable Syncthing daemon
    syncthing = {
      enable = true;
      group = "syncthing";
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
    python36Packages.glances
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
    smartmontools
    smplayer
    tmux
    unzip
    wget 
    youtube-dl
  ];
}
