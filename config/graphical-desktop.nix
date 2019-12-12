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
      dpi = 162;
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle,compose:ralt";

      displayManager = {
        sddm.enable = true;
        sessionCommands = ''
          # Force KDE file dialogs in GTK apps using xdg-desktp-portal
          export GTK_USE_PORTAL=1
          export PLASMA_USE_QT_SCALING=1
          export QT_SCREEN_SCALE_FACTORS=1.5
        '';
      };
      desktopManager.plasma5.enable = true;

      videoDrivers = [
        "nvidiaBeta"
      ];
      screenSection = ''
        Option "TripleBuffer" "on"
        Option "AllowIndirectGLXProtocol" "off"
        Option "metamodes" "3840x2160_120 +0+0 { ForceCompositionPipeline = On, ForceFullCompositionPipeline = On }"
      '';
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };

  environment.systemPackages = with pkgs; [
    amarok
    colord-kde
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
