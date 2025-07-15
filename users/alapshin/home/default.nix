{
  lib,
  pkgs,
  config,
  ...
}@args:
{
  home-manager.users."alapshin" = import ./home.nix (args // { username = "alapshin"; });
}
