{ config, pkgs, ... }:

{
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

  hardware.opengl =
    let 
      version = "22.0.0";
      attrs = oldAttrs: rec {
        inherit version;
        src = pkgs.fetchurl {
          urls = [
            "https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
          ];
          sha256 = "0l0jc23rk5s7lq8wgx4b6mxasb762lnw5kk7pn2p94drnll1ki76";
        };

        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dvulkan-layers=device-select,overlay" ];
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.glslang ];
        postInstall = oldAttrs.postInstall + ''
          mv $out/lib/libVkLayer* $drivers/lib
          layer=VkLayer_MESA_device_select
          substituteInPlace $drivers/share/vulkan/implicit_layer.d/''${layer}.json \
          --replace "lib''${layer}" "$drivers/lib/lib''${layer}"
          layer=VkLayer_MESA_overlay
          substituteInPlace $drivers/share/vulkan/explicit_layer.d/''${layer}.json \
          --replace "lib''${layer}" "$drivers/lib/lib''${layer}"
        '';
      }; 
      ovrd = _: {
        driDrivers = [];
      };
    in with pkgs; {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      package = ((mesa.override ovrd).overrideAttrs attrs).drivers;
      package32 = ((pkgsi686Linux.mesa.override ovrd).overrideAttrs attrs).drivers;
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
