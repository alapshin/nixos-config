{ pkgs
, osConfig
, dotfileDir
, ...
}: {
  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = false;
    };
  };
}
