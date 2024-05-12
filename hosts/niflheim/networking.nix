{ pkgs
, config
, ...
}: {
  networking = {
    hostName = "niflheim";
    useNetworkd = true;

    firewall = {
      enable = true;
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ 80 443 ];
    };
  };
  systemd.network = {
    enable = true;
  };
}
