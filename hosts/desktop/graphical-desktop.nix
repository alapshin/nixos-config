{
  lib,
  pkgs,
  config,
  ...
}:

{
  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };

  services.xserver.videoDrivers = [
    "amdgpu"
  ];
}
