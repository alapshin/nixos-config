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
  };

  environment.systemPackages = with pkgs; [
    traceroute
    wireguard-tools
  ];

}
