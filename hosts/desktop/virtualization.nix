{ config
, pkgs
, ...
}: {
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
    };
    podman.enable = true;
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    docker-compose
  ];
}
