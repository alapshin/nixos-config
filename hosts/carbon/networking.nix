{
  config,
  pkgs,
  ...
}: {
  networking = {
    hostName = "carbon";
    networkmanager.wifi.backend = "iwd";
  };
}
