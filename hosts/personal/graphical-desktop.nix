{
  lib,
  pkgs,
  config,
  ...
}:

{
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.xwayland.enable = true;

  services = {
    colord.enable = true;
    flatpak.enable = true;

    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
      };
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "plasma";
    };
    desktopManager.plasma6.enable = true;

    xserver = {
      enable = true;
      xkb = {
        dir = "${pkgs.xkeyboard-config-custom}/etc/X11/xkb";
        layout = lib.mkDefault "us,ru";
        variant = lib.mkDefault "hbs,srp";
        options = "grp:caps_toggle";
      };
      videoDrivers = [
        "vesa"
        "modesetting"
      ];
    };
  };

  environment.sessionVariables = {
    # https://xkbcommon.org/doc/current/group__include-path.html
    # runtime override supported by multiple libraries e. g. libxkbcommon
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config-custom}/etc/X11/xkb";
    # Workaround for
    # https://bugreports.qt.io/browse/QTBUG-113574?focusedId=723760
    # https://github.com/ankitects/anki/issues/1767#issuecomment-1827121475
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
  };
}
