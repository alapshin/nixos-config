{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "grp:caps_toggle,compose:ralt";
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    videoDrivers = [
      "nvidia"
    ];
  };
  hardware.opengl.driSupport32Bit = true;

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
