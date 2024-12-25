{
  lib,
  pkgs,
  dotfileDir,
  ...
}: {
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
}
