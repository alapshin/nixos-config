{
  lib,
  pkgs,
  config,
  ...
}:
{
  systemd.network.enable = true;

  networking = {
    # Use networkd instead of the pile of shell scripts
    useDHCP = lib.mkDefault false;
    useNetworkd = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    traceroute
    wireguard-tools
  ];

}
