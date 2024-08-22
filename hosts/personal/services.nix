{
  lib,
  pkgs,
  config,
  ...
}:
{
  services = {
    fwupd.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };
    auto-cpufreq = {
      enable = false;
      settings = {
        charger = {
          turbo = "auto";
          governor = "performance";
          scaling_min_freq = 3000000;
        };
        battery = {
          turbo = "auto";
          governor = "powersave";
          scaling_min_freq = 3000000;
        };
      };
    };
  };
}
