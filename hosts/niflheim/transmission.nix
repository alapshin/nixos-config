{ lib
, pkgs
, config
, ...
}: {
  services = {
    transmission = {
      enable = true;
      group = "media";
      openPeerPorts = true;
      webHome = pkgs.flood-for-transmission;
      settings = {
        download-dir = "/mnt/data/downloads";

        peer-port = 56789;
        port-forwarding-enabled = false;

        ratio-limit = 3.0;
        ratio-limit-enabled = true;

        rpc-whielist = "127.0.0.1";
        rpc-whitelist-enabled = true;
        rpc-host-whitelist-enabled = false;

      };
    };
    nginx-ext.applications."transmission" = {
      auth = true;
      port = config.services.transmission.settings.rpc-port;
    };
  };
  systemd.services.transmission.serviceConfig = {
    RestrictNetworkInterfaces = "lo wg0";
  };
}
