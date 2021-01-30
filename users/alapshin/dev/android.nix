{ config, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  programs.adb.enable = true;
  programs.java.enable = true;

  users.users."${username}".packages = with pkgs; [
    fhs-run
    groovy
    android-udev-rules
    jetbrains.idea-ultimate
    androidStudioPackages.stable
    androidStudioPackages.canary
  ];
}
