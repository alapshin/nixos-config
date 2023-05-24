{
  pkgs,
  config,
  dotfileDir,
  ...
}: let
  username = "alapshin";
in {
  home-manager.users."${username}" = import ./home.nix;
}
