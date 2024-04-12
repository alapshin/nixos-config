{ config
, pkgs
, ...
}: {
  services = {
    colord.enable = true;
    flatpak.enable = true;

    displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        defaultSession = "plasmawayland";
    };
    xserver = {
      dpi = 162;
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:caps_toggle,compose:ralt";
      };

      videoDrivers = [
        "amdgpu"
        "modesetting"
        "vesa"
      ];

      desktopManager.plasma5.enable = true;
    };
  };

  # Enable Vulkan layers
  # https://nixos.wiki/wiki/Mesa
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Force RADV drivers
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
