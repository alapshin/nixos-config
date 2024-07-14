{ config
, pkgs
, ...
}: {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
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
    desktopManager.plasma6.enable = true;

    xserver = {
      videoDrivers = [
        "amdgpu"
        "modesetting"
        "vesa"
      ];

    };
  };

  # Force RADV drivers
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
