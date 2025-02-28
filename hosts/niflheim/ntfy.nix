{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 8084;
in
{
  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        enable-login = true;
        enable-signup = false;
        auth-default-access = "deny-all";

        base-url = "https://ntfy.${config.services.webhost.basedomain}";
        behind-proxy = true;
        listen-http = "localhost:${toString port}";
      };
    };

    webhost.applications."ntfy" = {
      auth = false;
      port = port;
    };
  };
}
