{ config, pkgs, ... }:
{
  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services = {
    colord.enable = true;
    flatpak.enable = true;

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "plasma";
    };
    desktopManager.plasma6.enable = true;

    xserver = {
      videoDrivers = [
        "vesa"
        "amdgpu"
        "modesetting"
      ];

    };
  };
}
