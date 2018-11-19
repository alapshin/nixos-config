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
    redshift = {
      enable = true;
      provider = "manual";
      latitude = "58.5969";
      longitude = "49.6583";
      extraOptions = [ "-P" "-m randr" ];
    };
    # Enable Syncthing daemon
    syncthing = {
      enable = true;
      group = "syncthing";
    };
  };
}
