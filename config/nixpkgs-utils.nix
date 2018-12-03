{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    patchelf
    nix-index
    nix-prefetch-github
    nix-prefetch-scripts
  ];
}
