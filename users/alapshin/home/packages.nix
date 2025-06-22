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

    # Messaging
    slack

    # Fonts
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    nerd-fonts.jetbrains-mono

    noto-fonts-monochrome-emoji
  ];
}
