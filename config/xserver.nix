{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "grp:caps_toggle,compose:ralt";

    displayManager.sddm.enable = true;
    displayManager.sddm.enableHidpi = false;
    desktopManager.plasma5.enable = true;

    videoDrivers = [
      "nvidia"
    ];
    monitorSection = ''
      Option "UseEdidDpi" "True"
    '';
    screenSection = ''
      Option "TripleBuffer" "on"
      Option "AllowIndirectGLXProtocol" "off"
      Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On, ForceFullCompositionPipeline = On }"
    '';
  };

  environment.systemPackages = with pkgs; [
    amarok
    kdeApplications.ark
    kdeApplications.dolphin
    kdeApplications.filelight
    kdeApplications.gwenview
    kdeApplications.kmail
    kdeApplications.kmix
    kdeApplications.okular
    kdeconnect
    ktorrent
    partition-manager
    plasma-browser-integration 
    redshift-plasma-applet
    skrooge
  ];
}
