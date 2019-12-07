{ config, pkgs, ... }:

{
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    opengl = {
      s3tcSupport = true;
      driSupport32Bit = true;
    };
    nvidia.modesetting.enable = true;
  };

  services = {
    colord.enable = true;
    flatpak.enable = true;

    xserver = {
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle,compose:ralt";

      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;

      videoDrivers = [
        "nvidiaBeta"
      ];
      screenSection = ''
        Option "TripleBuffer" "on"
        Option "AllowIndirectGLXProtocol" "off"
        Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On, ForceFullCompositionPipeline = On }"
      '';
    };
  };

  xdg.portal = {
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  environment.systemPackages = with pkgs; [
    gtk2

    amarok
    colord-kde
    kate
    kdeApplications.ark
    kdeApplications.dolphin
    kdeApplications.filelight
    kdeApplications.gwenview
    kdeApplications.kwalletmanager
    kdeApplications.okular
    kdeApplications.spectacle
    kdeconnect
    ktorrent
    partition-manager
    plasma-browser-integration 
    skrooge
    thunderbird
  ];
}
