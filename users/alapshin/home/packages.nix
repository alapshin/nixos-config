{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # CLI
    age
    atool
    exiftool
    file
    ghostscript
    hadolint
    imagemagick
    lm_sensors
    moreutils
    openssl
    p7zip
    rsync
    shfmt
    shellcheck
    sops
    ssh-to-age
    stylua
    wget
    wl-clipboard
    unzip

    # Media
    ffmpeg

    # Fonts
    ibm-plex
    liberation_ttf
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra

    # Messaging
    element-desktop-wayland
  ];
}
