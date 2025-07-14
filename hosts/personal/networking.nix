{
  lib,
  pkgs,
  config,
  ...
}:

{
  networking = {
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };
}
