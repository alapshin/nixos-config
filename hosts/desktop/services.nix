{ lib
, pkgs
, config
, ...
}: {
  services = {
    avahi = {
      enable = true;
    };
    openssh = {
      enable = true;
    };
    geoclue2 = {
      enable = true;
    };
    automatic-timezoned = {
      enable = true;
    };
  };
}
