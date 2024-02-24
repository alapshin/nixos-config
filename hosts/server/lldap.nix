{ lib
, pkgs
, config
, domainName
, ...
}:
let
  host = config.services.lldap.settings.http_host;
  port = config.services.lldap.settings.http_port;
  user = config.services.lldap.settings.ldap_user_dn;
in
{
  sops = {
    secrets = {
      "lldap/jwt_secret" = { };
      "lldap/user_password" = { };
    };
  };
  services = {
    lldap = {
      enable = true;
      settings = {
        http_host = "localhost";
        ldap_host = "localhost";
        ldap_base_dn="dc=alapshin,dc=com";
        ldap_user_email = "${user}@${domainName}";
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = "%d/jwt_secret";
        LLDAP_LDAP_USER_PASS_FILE = "%d/user_password";
      };
    };

    nginx = {
      upstreams = {
        "ldap" = {
          servers = {
            "${host}:${toString port}" = { };
          };
        };
      };

      virtualHosts = {
        "ldap.${domainName}" = {
          forceSSL = true;
          useACMEHost = domainName;

          locations = {
            "/" = {
              proxyPass = "http://ldap";
              extraConfig = builtins.readFile ./nginx/proxy.conf;
            };
          };
        };
      };
    };
  };
  systemd.services.lldap = {
    serviceConfig = {
      LoadCredential = [
        "jwt_secret:${config.sops.secrets."lldap/jwt_secret".path}"
        "user_password:${config.sops.secrets."lldap/user_password".path}"
      ];
    };
  };
}