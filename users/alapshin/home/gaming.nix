{
  lib,
  pkgs,
  ...
}:
{
  programs.mangohud = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    enableSessionWide = true;
  };
}
