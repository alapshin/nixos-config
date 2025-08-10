{
  lib,
  pkgs,
  config,
  ...
}:

{

  services = {
    xserver = {
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle,compose:ralt";
      };

      videoDrivers = [ "nvidia" ];
    };
  };

  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
}
