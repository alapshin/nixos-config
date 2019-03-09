{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodePackages.npm
    nodePackages.node2nix
  ];
}
