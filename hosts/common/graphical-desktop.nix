{ config
, pkgs
, ...
}: {
  qt = {
    enable = true;
    platformTheme = "kde";
  };
  programs.xwayland.enable = true;

  services = {
    xserver = {
      enable = true;
      xkbDir = "${pkgs.xkbconfig_custom}/etc/X11/xkb";
      layout = "us,ru";
      xkbVariant = "hbs,srp";
      xkbOptions = "grp:caps_toggle,compose:lwin";

      libinput = {
        enable = true;
        touchpad = {
          disableWhileTyping = true;
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  environment.sessionVariables = {
    # https://xkbcommon.org/doc/current/group__include-path.html
    # runtime override supported by multiple libraries e. g. libxkbcommon
    XKB_CONFIG_ROOT = "${pkgs.xkbconfig_custom}/etc/X11/xkb";
  };
}
