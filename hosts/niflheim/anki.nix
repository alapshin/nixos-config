{ config, ... }:

{
  sops.secrets = {
    "anki/user1_password" = { };
  };

  services = {
    anki-sync-server = {
      enable = true;
      address = "127.0.0.1";
      users = [
        {
          username = "user1";
          passwordFile = config.sops.secrets."anki/user1_password".path;
        }
      ];
    };

    webhost.applications."anki" = {
      auth = false;
      port = config.services.anki-sync-server.port;
    };
  };
}
