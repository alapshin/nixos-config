{ config, pkgs, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
    };
    podman.enable = true;
  };

  environment.systemPackages = with pkgs; [ docker-compose ];
}
