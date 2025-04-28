{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.forgejo;
  host = "forgejo.${config.services.webhost.basedomain}";
in
{
  sops.secrets = {
    "forgejo/admin_password" = {
      owner = cfg.user;
      group = cfg.group;
    };
  };

  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
    };
    settings = {
      server = {
        HTTP_PORT = 3050;
        HTTP_ADDR = "127.0.0.1";
        DOMAIN = host;
        ROOT_URL = "https://${host}";
      };
      service = {
        ENABLE_INTERNAL_SIGNIN = true;
        SHOW_REGISTRATION_BUTTON = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;

        ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
        REVERSE_PROXY_AUTHENTICATION_HEADER = "Remote-User";
      };
    };
  };

  services.webhost.applications."forgejo" = {
    auth = true;
    port = config.services.forgejo.settings.server.HTTP_PORT;
  };

  systemd.services.forgejo.preStart =
    let
      user = "root"; # Note, Forgejo doesn't allow creation of an account named "admin"
      adminCmd = "${lib.getExe cfg.package} admin user";
      passwordFile = config.sops.secrets."forgejo/admin_password".path;
    in
    ''
      ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${passwordFile})" || true
    '';
}
