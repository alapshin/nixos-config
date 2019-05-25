{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gitRepo
    gitAndTools.git
    gitAndTools.tig
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.git-extras
  ];
}
