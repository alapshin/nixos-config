{ config
, lib
, pkgs
, ...
}: {
  imports = [
    ./networking.nix
    ./hardware-configuration.nix
  ];
}
