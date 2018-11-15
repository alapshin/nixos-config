{ config, pkgs, ... }:

{
  services = {
    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence "warning: mlocate does not support searching as user other than root"
      localuser = null;
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
