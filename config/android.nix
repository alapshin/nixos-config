{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.ccache.enable = true;
  programs.java = {
    enable = true;
    package = pkgs.adoptopenjdk-openj9-bin-11;
  };
  environment.systemPackages = with pkgs; [
    android-udev-rules
    android-fhs-run
    jetbrains.idea-ultimate
    androidStudioPackages.beta
    androidStudioPackages.stable
  ];
}
