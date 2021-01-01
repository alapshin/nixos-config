{ config, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./cli.nix
    ./home.nix
    ./shell.nix
  ];

  users.users.alapshin = {
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
