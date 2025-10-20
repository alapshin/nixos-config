{ pkgs, ... }:
{
  programs = {
    mpv = {
      enable = true;
    };
    joplin-desktop = {
      enable = true;
      extraConfig = {
        "locale" = "en_GB";
        "dateFormat" = "YYYY-MM-DD";
        "showTrayIcon" = true;
      };
    };
    keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        Browser = {
          Enabled = true;
          UpdateBinaryPath = false;
        };
        GUI = {
          AdvancedSettings = true;
          ApplicationTheme = "classic";
          ShowTrayIcon = true;
          MinimizeToTray = true;
          MinimizeOnClose = true;
          TrayIconAppearance = "monochrome-dark";
        };
        Security = {
          IconDownloadFallback = true;
        };
        SSHAgent.Enabled = true;
        FdoSecrets.Enabled = true;
      };
    };
    element-desktop = {
      enable = true;
    };

    man.generateCaches = false;

    obs-studio = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        obs-composite-blur
        obs-move-transition
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };

  home.packages =
    with pkgs;
    [
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
      telegram-desktop
      wget
      unzip
      zoom-us

      # Media
      ffmpeg

      # Messaging
      slack

      # Fonts
      liberation_ttf
      noto-fonts
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji

      # Needed for deploying remote hosts from darwin
      nixos-rebuild-ng
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      wl-clipboard
      rustdesk-flutter
    ]
    ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
      iina
      keka
      maccy
      skimpdf
      rectangle
      betterdisplay
    ];
}
