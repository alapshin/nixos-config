{ config, pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = false;
  };

  environment.systemPackages = with pkgs; [
    virtmanager
    docker_compose
    docker-machine
  ];
}
