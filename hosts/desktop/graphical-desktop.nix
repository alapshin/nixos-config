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

  services.xserver = {
    xkb = {
      layout = "us,ru,us";
      variant = "hbs,srp,altgr-intl";
    };
  };

  services.xserver.videoDrivers = [
    "amdgpu"
  ];
}
