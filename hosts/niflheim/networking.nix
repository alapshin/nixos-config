{ pkgs
, config
, ...
}: {
  networking = {
    hostName = "niflheim";
    useNetworkd = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  systemd.network = {
    enable = true;

    # See https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
    networks."10-wan" = {
      # Either ens3 (amd64) or enp1s0 (arm64)
      matchConfig.Name = "enp6s0";
      networkConfig = {
        DHCP = "ipv4";
        Gateway = "fe80::1";
        Address = "2a01:4f9:3070:2556::/64";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    traceroute
    wireguard-tools
  ];

}
