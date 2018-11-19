{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch-github
    nix-prefetch-scripts
  ];
}
