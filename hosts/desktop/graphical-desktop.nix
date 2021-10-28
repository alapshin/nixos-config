{ config, pkgs, ... }:

{
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

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
      dpi = 162;
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle,compose:ralt";

      videoDrivers = [
        "amdgpu"
        "modesetting"
        "vesa"
      ];
      deviceSection = ''
        Option "TearFree" "true"
        Option "VariableRefresh" "true"
      '';

      displayManager = {
        sddm.enable = true;
        sessionCommands = ''
          # export GDK_SCALE=2
          # export GDK_DPI_SCALE=0.5
          export PLASMA_USE_QT_SCALING=1
          export QT_SCREEN_SCALE_FACTORS=1.5
        '';
        defaultSession = "plasma";
      };
      desktopManager.plasma5.enable = true;
    };
  };
}
