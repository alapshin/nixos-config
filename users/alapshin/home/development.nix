{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # hurl
    httpie
  ];
}
