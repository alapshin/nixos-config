{
  lib,
  pkgs,
  config,
  ...
}:
{
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
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle,compose:ralt";
      };

      videoDrivers = [ "nvidia" ];
    };
  };

  hardware.nvidia.modesetting.enable = true;
}
