{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.caddy = {
    enable = true;
    globalConfig = ''
      https_port 8444

      # Disable HTTP/3 — port is external but advertising Alt-Svc would reveal the real port
      servers {
        protocols h1 h2
      }
    '';

    # REALITY fallback front — Xray forwards active probes here so external
    # scanners see a legitimate TLS handshake. Certificate obtained via HTTP-01
    # challenge (port 80); Xray owns 443 so https_port is remapped to 8444.
    virtualHosts."ip-212-193-3-155.my-advin.com:8444".extraConfig = ''
      respond 200 {
        close
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
