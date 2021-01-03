{ config, myutils, pkgs, ... }:

let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  users.users."${username}".packages = with pkgs; [
    atool
    bat
    bcache-tools
    borgbackup
    exa
    fd
    file
    gnupg
    htop
    httpie
    http-prompt
    imagemagick
    jq
    lm_sensors
    manpages
    moreutils
    ncdu
    neovim
    nnn
    p7zip
    pandoc
    pciutils
    ripgrep
    rsync
    smartmontools
    tmux
    tree
    unrar
    unzip
    usbutils
    wget
    youtube-dl
  ];
}
