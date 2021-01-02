{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
