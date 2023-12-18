{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    home-manager

    # AI
    openai-whisper

    # Media
    mpv
    ffmpeg

    jq
    hadolint
    moreutils
    shellcheck

    # Fonts
    ibm-plex
    liberation_ttf
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
  ];
}
