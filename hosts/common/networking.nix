{
  config,
  pkgs,
  ...
}: {
  networking = {
    firewall.enable = false;
    wireless.dbusControlled = true;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      plugins = with pkgs; [
        networkmanager-sstp
        networkmanager-openvpn
      ];
    };
  };
}
