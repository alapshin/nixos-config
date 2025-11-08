{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "bookloore/database_password" = { };
      "booklore/oidc_client_secret" = { };
    };
    templates."booklore.env".content = ''
      DATABASE_PASSWORD=${config.sops.placeholder."booklore/database_password"}
      AUTHELIA_CLIENT_ID=booklore
      AUTHELIA_CLIENT_SECRET=${config.sops.placeholder."booklore/oidc_client_secret"}
    '';
  };

  services = {
    booklore = {
      enable = true;
      port = 8090;
      environmentFile = config.sops.templates."booklore.env".path;
    };

    webhost.applications."booklore" = {
      auth = false;
      port = config.services.booklore.port;
    };
  };
}
