{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.java.enable = true;
  environment.systemPackages = with pkgs; [
    openjdk
  ];
}
