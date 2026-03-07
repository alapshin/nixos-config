{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "porkbun/api_key" = { };
      "porkbun/secret_key" = { };
    };
    templates."caddy.env" = {
      restartUnits = [ "caddy.service" ];
      content = ''
        PORKBUN_API_KEY=${config.sops.placeholder."porkbun/api_key"}
        PORKBUN_API_SECRET_KEY=${config.sops.placeholder."porkbun/secret_key"}
      '';
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-cM9ez2i9ZADbXSI7KNZlBCe1F1vpX5fH++qKILaHguA=";
    };
    environmentFile = config.sops.templates."caddy.env".path;
    globalConfig = ''
      https_port 8442
      default_bind 127.0.0.1

      # Disable HTTP/3 — ports are internal, must not be advertised via Alt-Svc
      servers {
        protocols h1 h2
      }

      acme_dns porkbun {
        api_key {env.PORKBUN_API_KEY}
        api_secret_key {env.PORKBUN_API_SECRET_KEY}
      }
    '';
    # Wildcard certificate: Caddy 2.10+ reuses this cert for all individual
    # *.bitgarage.dev virtualHosts, so they don't each trigger separate issuance.
    virtualHosts."bitgarage.dev, *.bitgarage.dev".extraConfig = ''
      abort
    '';

    # REALITY fallback front — binds exclusively on port 8444
    # so it is never reachable via the app listener (port 8443).
    # Xray forwards active probes here; real tunnel clients go to app vhosts on port 8443.
    virtualHosts."hello.bitgarage.dev:8444".extraConfig = ''
      respond 200 {
        close
      }
    '';

    # Block any other subdomain that arrives on the REALITY fallback port (8444).
    # Without this, unmatched SNIs fall through to hello.bitgarage.dev:8444 as the default vhost on that listener.
    virtualHosts."*.bitgarage.dev:8444, bitgarage.dev:8444".extraConfig = ''
      abort
    '';
  };
}
