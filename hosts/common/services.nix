{ config
, pkgs
, ...
}: {
  services.fwupd.enable = true;
  services.auto-cpufreq = {
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
}
