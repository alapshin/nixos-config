{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    patchelf
    nix-index
    nix-prefetch-git
    nix-prefetch-github
  ];
}
