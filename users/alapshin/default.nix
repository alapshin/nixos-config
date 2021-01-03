{ config, lib, myutils, pkgs, ... }:

let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  imports = [
    ./apps.nix
    ./cli.nix
    ./home.nix
    ./shell.nix

    ./dev/git.nix
    ./dev/shell.nix
    ./dev/python.nix
    ./dev/android.nix
  ];

  users.users."${username}" = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Andrei Lapshin";
    initialPassword = "12345678";
    extraGroups = [
      "adbusers"
      "audio"
      "docker"
      "input"
      "jackaudio"
      "libvirtd"
      "networkmanager"
      "syncthing"
      "wheel"
    ];
  };
}
