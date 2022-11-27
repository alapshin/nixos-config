{
  config,
  pkgs,
  ...
}: {
  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
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
      dpi = 120;
      videoDrivers = ["modesetting" "intel"];

      displayManager = {
        # startx.enable = true;
        sddm.enable = true;
        defaultSession = "plasma";
      };
      desktopManager.plasma5.enable = true;
    };
  };
}
