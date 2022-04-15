{ config, pkgs, ... }:

{
  services = {
    openssh = {
      enable = true;
      ports = [
        2200
      ];
    };
  };
}
