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
      settings = {
        Browser.Enabled = true;
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

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        obs-composite-blur
        obs-move-transition
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = [
        "${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop"
      ];
    };
  };
}
