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
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji

    # Messaging
    element-desktop-wayland
  ];
}
