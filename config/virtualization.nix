{ config, pkgs, ... }:

{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virtmanager
    docker_compose
    docker-machine
  ];
}
