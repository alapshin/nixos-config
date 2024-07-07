{ lib
, pkgs
, config
, ...
}:
let
  port = 10000;
  host = "127.0.0.1";
in
{
  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.${config.domain.base}";
        behind-proxy = true;
        listen-http = "${host}:${toString port}";

        enable-login = false;
        enable-signup = false;
        auth-default-access = "deny-all";
      };
    };

    nginx-ext.applications."ntfy" = {
      auth = true;
      port = port;
      proxyWebsockets = true;
    };
  };
}
