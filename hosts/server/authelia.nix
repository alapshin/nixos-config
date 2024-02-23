{ lib
, pkgs
, config
, domainName
, ...
}:
let
  port = 9091;
  instance = "main";
  ldapHost = config.services.lldap.settings.ldap_host;
  ldapPort = config.services.lldap.settings.ldap_port;
  ldapBaseDN = config.services.lldap.settings.ldap_base_dn;
  ldapUserDN = config.services.lldap.settings.ldap_user_dn;
  ldapUserOU = "ou=people";
  ldapUsernameAttr = "uid";
  ldapFullUser = "${ldapUsernameAttr}=${ldapUserDN},${ldapUserOU},${ldapBaseDN}";
in
{

  sops = {
    secrets = {
      "authelia/users" = {
        format = "binary";
        sopsFile = ./secrets/auth_users.yml.bin;
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/jwt_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/session_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/storage_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
    };
  };

  services = {
    nginx = {
      upstreams = {
        "authelia" = {
          servers = {
            "localhost:${toString port}" = { };
          };
        };
      };

      virtualHosts = {
        "auth.${domainName}" = {
          forceSSL = true;
          useACMEHost = domainName;

          locations = {
            "/" = {
              proxyPass = "http://authelia";
              extraConfig = builtins.readFile ./nginx/proxy.conf;
            };
            "/api/verify" = {
              proxyPass = "http://authelia";
            };
          };
        };
      };
    };

    authelia.instances."${instance}" = {
      enable = true;
      settings = {
        log = {
          level = "debug";
          format = "text";
        };
        server = {
          port = port;
          host = "localhost";
        };
        session = {
          name = "auth";
          domain = domainName;
        };
        access_control = {
          default_policy = "deny";
          rules = [
            {
              policy = "bypass";
              domain = "auth.${domainName}";
            }
            {
              policy = "one_factor";
              domain = [ "*.${domainName}" ];
            }
          ];
        };
        authentication_backend = {
          ldap = {
            url = "ldap://${ldapHost}:${toString ldapPort}";
            user = ldapFullUser;
            base_dn = ldapBaseDN;
            mail_attribute = "mail";
            username_attribute = ldapUsernameAttr;
            display_name_attribute = "displayName";
            groups_filter = "(member={dn})";
            additional_groups_dn = "ou=groups";
            users_filter = "(&({username_attribute}={input})(objectClass=person))";
            additional_users_dn = ldapUserOU;
          };
        };
        storage = {
          local = {
            path = "/var/lib/authelia-${instance}/db.sqlite3";
          };
        };
        notifier = {
          filesystem = {
            filename = "/var/lib/authelia-${instance}/notification.txt";
          };
        };
        default_2fa_method = "totp";
      };
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storage_secret".path;
      };
    };
  };

  systemd.services."authelia-${instance}" = {
    environment = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldap_password";
    };
    serviceConfig = {
      LoadCredential = [
        "ldap_password:${config.sops.secrets."lldap/user_password".path}"
      ];
    };
  };
}
