{
  config,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
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
    man-pages
    moreutils
    ncdu
    neovim
    nnn
    openssl
    p7zip
    pandoc
    pciutils
    ripgrep
    rsync
    s-tui
    stress-ng
    smartmontools
    tree
    unrar
    unzip
    usbutils
    wget
    yt-dlp
    youtube-dl
  ];
}
