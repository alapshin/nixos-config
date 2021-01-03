{ config, myutils, pkgs, ... }:
let
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  users.users."${username}".packages = with pkgs; [
    git-lfs
    gitAndTools.gh
    gitAndTools.git
    gitAndTools.tig
    gitAndTools.gitui
    gitAndTools.git-crypt
    gitAndTools.transcrypt
    gitAndTools.git-extras
    gitAndTools.git-filter-repo
  ];
}
