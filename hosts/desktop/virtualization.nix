{ config, pkgs, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
    };
    podman.enable = true;
    libvirtd.enable = false;
  };

  programs.virt-manager.enable = false;

  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
  ];
}
