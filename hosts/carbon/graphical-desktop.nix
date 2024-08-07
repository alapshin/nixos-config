{ config
, pkgs
, ...
}: {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };
  };

  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde";
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
    xserver = {
      videoDrivers = [ "modesetting" "intel" ];
    };
    desktopManager.plasma6.enable = true;
  };

  # Workaround for 
  # https://bugreports.qt.io/browse/QTBUG-113574?focusedId=723760
  # https://github.com/ankitects/anki/issues/1767#issuecomment-1827121475
  environment.variables = {
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
  };

  environment.systemPackages = with pkgs; [
  ];
}
