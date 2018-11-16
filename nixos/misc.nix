{ config, pkgs, ... }:

{
  services = {
    geoclue2 = {
      enable = true;
    };
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
      provider = "geoclue2";
      extraOptions = [ "-P" "-m randr" ];
    };
    # Enable Syncthing daemon
    syncthing = {
      enable = true;
      group = "syncthing";
    };
  };
}
