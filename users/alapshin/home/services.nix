{
  lib,
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
  };
}
