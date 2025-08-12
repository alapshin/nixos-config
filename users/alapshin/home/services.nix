{
  pkgs,
  osConfig,
  ...
}:
{
  services = {
    safeeyes.enable = pkgs.stdenv.hostPlatform.isLinux;
    flameshot.enable = pkgs.stdenv.hostPlatform.isLinux;
    nextcloud-client = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      startInBackground = false;
    };
  };
}
