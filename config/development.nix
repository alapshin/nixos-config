{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.java.enable = true;
  environment.systemPackages = with pkgs; [
    openjdk
    android-udev-rules
    gitAndTools.gitFull
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.tig
  ];
}
