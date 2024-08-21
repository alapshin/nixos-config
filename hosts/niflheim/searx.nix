{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "searx/secret_key" = { };
    };
    templates."searx/secret_key.env".content = ''
      SEARXNG_SECRET=${config.sops.placeholder."searx/secret_key"}
    '';
  };
  services = {
    searx = {
      enable = true;
      settings = {
        use_default_settings = true;
        server = {
          port = 8181;
          bind_address = "127.0.0.1";
          image_proxy = true;
          public_instance = false;
        };
      };
      environmentFile = config.sops.templates."searx/secret_key.env".path;
    };
    nginx-ext.applications = {
      "searx" = {
        auth = true;
        port = config.services.searx.settings.server.port;
      };
    };
  };
}
