{ config, pkgs, ... }:

{
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
      "networkmanager"
      "syncthing"
      "wheel" 
    ];
  };
}
