{ lib
, pkgs
, config
, domainName
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
        base-url = "https://ntfy.${domainName}";
        behind-proxy = true;
        listen-http = "${host}:${toString port}";

        enable-login = false;
        enable-signup = false;
        auth-default-access = "deny-all";
      };
    };
    nginx.virtualHosts = {
      "ntfy.${domainName}" = {
        locations."/" = {
          proxyWebsockets = true;
        };
      };
    };
    nginx-ext.applications."ntfy" = {
      auth = true;
      port = port;
    };
  };
}
