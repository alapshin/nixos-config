{ lib, ... }:

{
  imports = [
    ./nix.nix

    ./audio.nix
    ./boot.nix
    ./bluetooth.nix
    ./networking.nix
    ./services.nix
    ./syncthing.nix
    ./virtualization.nix

    ./graphical-desktop.nix
  ];

  console = {
    font = "latarcyrheb-sun32";
    earlySetup = true;
    useXkbConfig = true;
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [ "IBM Plex Serif" ];
        sansSerif = [ "IBM Plex Sans" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
    enableDefaultPackages = false;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_DK.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  time = {
    timeZone = "Europe/Belgrade";
  };
}
