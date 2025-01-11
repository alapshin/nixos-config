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
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "1.25";
  };
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
