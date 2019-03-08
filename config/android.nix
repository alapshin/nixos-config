{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.ccache.enable = true;
  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
  environment.systemPackages = with pkgs; [
    android-udev-rules
    android-fhs-run
    jetbrains.idea-ultimate
    androidStudioPackages.beta
  ];
}
