{
  config,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
  programs.adb.enable = true;
  programs.java.enable = true;

  users.users."${username}".packages = with pkgs; [
    async-profiler

    groovy
    scrcpy
    android-udev-rules
    jetbrains.idea-ultimate
    androidStudioPackages.stable
    androidStudioPackages.beta
    androidStudioPackages.canary
  ];
}
