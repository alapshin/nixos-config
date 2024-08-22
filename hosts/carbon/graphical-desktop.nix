{
  lib,
  pkgs,
  config,
  ...
}:

{
  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };
  };

  services.xserver.videoDrivers = [
    "intel"
  ];
}
