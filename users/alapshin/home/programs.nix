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
        SSHAgent.Enabled = true;
        FdoSecrets.Enabled = true;
      };
    };
    element-desktop = {
      enable = true;
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
