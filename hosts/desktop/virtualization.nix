{
  config,
  pkgs,
  ...
}: {
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    docker-compose
  ];
}
