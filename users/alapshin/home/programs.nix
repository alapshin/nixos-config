{ pkgs, ... }:
{
  programs = {
    mpv = {
      enable = true;
    };
    keepassxc = {
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
