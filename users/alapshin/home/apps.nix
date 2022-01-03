{ config, dirs, myutils, pkgs, ... }:

let
  hmcfg = config.home-manager.users."${username}";
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  home-manager.users."${username}" = {
    programs.tmux = {
      enable = true;
    };
  };
}
