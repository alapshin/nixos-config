{
  pkgs,
  osConfig,
  ...
}:
let
  hostname = osConfig.networking.hostName;
in
{
  services = {
    safeeyes.enable = pkgs.stdenv.hostPlatform.isLinux;
    flameshot.enable = pkgs.stdenv.hostPlatform.isLinux;
    nextcloud-client = {
      enable = hostname == "desktop" || hostname == "carbon";
      startInBackground = false;
    };
  };
}
