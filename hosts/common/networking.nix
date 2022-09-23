{
  config,
  pkgs,
  ...
}: {
  networking = {
    networkmanager.wifi.backend = "iwd";
  };
}
