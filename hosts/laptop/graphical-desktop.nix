{
  config,
  pkgs,
  ...
}: {
  environment.variables = {
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  services = {
    colord.enable = true;
    flatpak.enable = true;

    xserver = {
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle,compose:ralt";

      videoDrivers = ["modesetting" "intel"];

      displayManager = {
        sddm.enable = true;
        sessionCommands = ''
        '';
      };
      desktopManager.plasma5.enable = true;
    };
  };
}
