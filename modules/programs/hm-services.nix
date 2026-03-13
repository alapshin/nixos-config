# services home-manager configuration - home-manager aspect
{ ... }:
{
  flake.modules.homeManager.services =
    {
      lib,
      pkgs,
      ...
    }:
    {
      services = {
        safeeyes.enable = pkgs.stdenv.hostPlatform.isLinux;
        flameshot.enable = pkgs.stdenv.hostPlatform.isLinux;
      };
    };
}
