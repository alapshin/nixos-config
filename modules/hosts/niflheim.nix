{ inputs, config, ... }:
{
  flake.modules.nixos.host-niflheim = {
    imports =
      with inputs.self.modules.nixos;
      [
        server
        niflheim-backup
        # Server infrastructure
        caddy
        authelia
        lldap
        # Services
        ai
        anki
        audiobookshelf
        bitmagnet
        calibre
        changedetection
        dashboard
        docling
        forgejo
        freshrss
        grafana
        handbrake
        immich
        influxdb
        jellyfin
        karakeep
        linkwarden
        monica
        netbird
        nextcloud
        nginx
        ntfy
        paperless
        pinepods
        postgres
        prometheus
        scrutiny
        searx
        servarr
        transmission
        wireguard
        ./_hosts/niflheim
      ]
      ++ [
        # Custom service option modules
        (config.flake.modules.nixos.vpn or { })
        (config.flake.modules.nixos.webhost or { })
        (config.flake.modules.nixos.monica-service or { })
      ];
  };
}
