{ config, pkgs, ... }:

{
  programs.adb.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk14;
  };

  environment.systemPackages = with pkgs; [
    fhs-run
    groovy
    android-udev-rules
    jetbrains.idea-ultimate
    androidStudioPackages.stable
  ];
}
