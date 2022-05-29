{
  config,
  lib,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
  imports = [
    ./home

    ./apps.nix
    ./cli.nix
    ./services.nix

    ./dev/git.nix
    ./dev/shell.nix
    ./dev/python.nix
    ./dev/android.nix
  ];

  programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;
  programs.kdeconnect.enable = true;
  programs.partition-manager.enable = true;

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
