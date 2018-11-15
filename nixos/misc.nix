{ config, pkgs, ... }:

{
  services = {
    locate = {
      enable = true;
      locate = pkgs.mlocate;
    };
    # Enable CUPS
    printing = {
      enable = true;
      drivers = [
        pkgs.hplip
      ];
    };
    # Enable Syncthing daemon
    syncthing = {
      enable = true;
      group = "syncthing";
    };
  };
}
