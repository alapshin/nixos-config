{ pkgs, ... }:
{
  programs = {
    mpv = {
      enable = true;
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
