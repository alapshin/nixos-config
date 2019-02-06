{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustc
    cargo

    binutils 
    gcc 
    gnumake
    openssl
    pkgconfig
  ];
}
