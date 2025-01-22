{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
    protontricks.enable = true;
  };
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
      openFirewall = true;
    };

    udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
  };
  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "1.25";
  };
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
