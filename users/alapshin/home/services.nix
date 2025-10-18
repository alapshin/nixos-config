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

  home.packages =
    lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
      pkgs.flameshot
    ];
  services = {
    safeeyes.enable = pkgs.stdenv.hostPlatform.isLinux;
    flameshot.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
