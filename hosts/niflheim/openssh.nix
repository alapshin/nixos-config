{ lib
, pkgs
, config
, ...
}: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
  };
}

