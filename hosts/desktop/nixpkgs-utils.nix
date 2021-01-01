{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nix-index
    nix-prefetch-git
    nix-prefetch-github
    nixpkgs-fmt
  ];
}
