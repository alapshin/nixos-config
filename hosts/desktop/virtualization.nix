{ config, pkgs, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
    };
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    dmg2img
    qemu_kvm
    docker-compose
    podman-compose
  ];
}
