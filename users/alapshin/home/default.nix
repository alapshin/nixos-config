{
  lib,
  pkgs,
  config,
  ...
}@args:
let
  username = if pkgs.stdenv.hostPlatform.isLinux then "alapshin" else "andrei.lapshin";
in
{
  home-manager.users."${username}" = import ./home.nix (args // { inherit username; });
}
