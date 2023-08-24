{ config
, pkgs
, ...
}: {
  services.fwupd.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        turbo = "always";
        governor = "performance";
      };
      battery = {
        turbo = "never";
        governor = "powersave";
      };
    };
  };
}
