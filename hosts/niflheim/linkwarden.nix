{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "linkwarden/nextauth_secret" = { };
      "linkwarden/oidc_client_secret" = { };
    };
    templates."linkwarden.env".content = ''
      NEXTAUTH_SECRET=${config.sops.placeholder."linkwarden/nextauth_secret"}
      AUTHELIA_CLIENT_ID=linkwarden
      AUTHELIA_CLIENT_SECRET=${config.sops.placeholder."linkwarden/oidc_client_secret"}
    '';
  };

  services = {
    linkwarden = {
      enable = true;
      port = 8087;
      environment = {
        NEXT_PUBLIC_AUTHELIA_ENABLED = "true";
        NEXTAUTH_URL = "https://linkwarden.${config.services.webhost.basedomain}/api/v1/auth";
        AUTHELIA_WELLKNOWN_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
      };
      environmentFile = config.sops.templates."linkwarden.env".path;
    };

    webhost.applications."linkwarden" = {
      auth = false;
      port = config.services.linkwarden.port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "linkwarden";
              client_name = "Linkwarden";
              client_secret = "$pbkdf2-sha512$310000$Uy.9Qxe3HGREcEYP0xTpKQ$ISAzvo7ZcSnqYMRdUL2.ZTaIzgrG4HnjruDfxDvAdceCW.vfdu8dyfUr/fiMyvXNYaRX2YSfmcRnfL5vH10qOw";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://linkwarden.${config.services.webhost.basedomain}/api/v1/auth/callback/authelia"
              ];
            }
          ];
        };
      };
    };

  };
}
