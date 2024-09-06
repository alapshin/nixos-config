{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "navidrome/salt" = { };
      "navidrome/token" = { };
    };
  };

  services = {
    navidrome = {
      enable = true;
      settings = {
        MusicFolder = "/mnt/data/music";
        ReverseProxyWhitelist = "127.0.0.1/8";
      };
    };
    nginx-ext.applications."navidrome" = {
      auth = true;
      port = config.services.navidrome.settings.Port;
    };
  };
}
