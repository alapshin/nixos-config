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
      redisCreateLocally = true;
      settings = {
        use_default_settings = true;
        server = {
          port = 8181;
          bind_address = "127.0.0.1";
          method = "GET";
          limiter = false;
          image_proxy = true;
          public_instance = false;
        };
        search = {
          formats = [
            "html"
            "json"
          ];
        };
      };
      limiterSettings = {
        botdetection.ip_limit.link_token = false;
        botdetection.ip_limit.filter_link_local = false;
      };
      environmentFile = config.sops.templates."searx/secret_key.env".path;
    };

    webhost.applications."searx" = {
      auth = true;
      port = config.services.searx.settings.server.port;
    };
  };
}
