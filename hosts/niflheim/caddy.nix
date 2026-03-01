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
      hash = "sha256-C+eTduZvOlewyzOxtTqmmWXL2yVqAq/ltq+XrzD1otY=";
    };
    environmentFile = config.sops.templates."caddy.env".path;
    globalConfig = ''
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
  };
}
