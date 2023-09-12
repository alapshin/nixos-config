{ config
, pkgs
, ...
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

  services = {
    colord.enable = true;
    flatpak.enable = true;

    xserver = {
      videoDrivers = [ "modesetting" "intel" ];

      displayManager = {
        # startx.enable = true;
        sddm.enable = true;
        defaultSession = "plasmawayland";
      };
      desktopManager.plasma5.enable = true;
    };
  };
}
