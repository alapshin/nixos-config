{
  lib,
  pkgs,
  config,
  ...
}:
{
  systemd.network.enable = true;
  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    traceroute
    wireguard-tools
  ];

}
