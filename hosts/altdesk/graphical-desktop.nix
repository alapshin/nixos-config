{ config, pkgs, ... }:

{
  hardware.nvidia.modesetting.enable = true;

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  services = {
    colord.enable = true;
    flatpak.enable = true;

    xserver = {
      dpi = 96;
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle,compose:ralt";

      videoDrivers = [
        "nvidia"
      ];
      displayManager = {
        sddm.enable = true;
      };
      desktopManager.plasma5.enable = true;

      screenSection = ''
        Option "TripleBuffer" "on"
        Option "AllowIndirectGLXProtocol" "off"
        Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      '';
    };
  };
}
