{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.ccache.enable = true;
  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
  environment.systemPackages = with pkgs; [
    shellcheck
    android-udev-rules
    gitAndTools.git
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.tig
  ];
}
