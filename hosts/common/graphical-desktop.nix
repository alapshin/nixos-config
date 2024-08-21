{ config, pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme = "kde";
  };
  programs.xwayland.enable = true;

  services = {
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
      };
    };

    xserver = {
      enable = true;
      xkb = {
        dir = "${pkgs.xkbconfig_custom}/etc/X11/xkb";
        layout = "us,ru";
        variant = "hbs,srp";
        options = "grp:caps_toggle";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };

  environment.sessionVariables = {
    # https://xkbcommon.org/doc/current/group__include-path.html
    # runtime override supported by multiple libraries e. g. libxkbcommon
    XKB_CONFIG_ROOT = "${pkgs.xkbconfig_custom}/etc/X11/xkb";
  };
}
