{
  pkgs,
  osConfig,
  dotfileDir,
  ...
}:
{
  services = {
    safeeyes.enable = true;
    nextcloud-client = {
      enable = true;
      startInBackground = false;
    };
  };
}
