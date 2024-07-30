{ lib
, pkgs
, config
, ...
}: {
  networking = {
    firewall.enable = false;
    wireless.dbusControlled = true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
