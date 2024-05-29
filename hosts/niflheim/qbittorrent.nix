{ lib
, pkgs
, config
, domainName
, ...
}: {
  services = {
    qbittorrent = {
      enable = true;
      group = "media";
    };
    nginx-ext.applications."qbittorrent" = {
      auth = true;
      port = config.services.qbittorrent.port;
    };
  };

  systemd = {
    tmpfiles = {
      settings = {
        "10-qbittorrent" = {
          "/mnt/data/downloads" = {
            d = {
              mode = "0775";
              user = config.services.qbittorrent.user;
              group = config.users.groups.media.name;
            };
          };
        };
      };
    };
  };

  networking = {
    firewall.interfaces."wg0" = {
      allowedTCPPorts = [ 54321 ];
      allowedUDPPorts = [ 54321 ];
    };
  };

  users.users.qbittorrent.extraGroups = [ "media" ];
}
