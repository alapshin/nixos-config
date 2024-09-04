{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hurl
    xh
    yamlfmt
  ];
}
