{ lib
, pkgs
, config
, domainName
, ...
}:
let
  instance = "main";
  dbHost = "/run/postgresql";
  dbName = "authelia-${instance}";
  dbUser = "authelia-${instance}";
  dbPort = config.services.postgresql.port;
  ldapHost = config.services.lldap.settings.ldap_host;
  ldapPort = config.services.lldap.settings.ldap_port;
  ldapBaseDN = config.services.lldap.settings.ldap_base_dn;
  ldapUserDN = config.services.lldap.settings.ldap_user_dn;
  ldapUserOU = "ou=people";
  ldapUsernameAttr = "uid";
  ldapFullUser = "${ldapUsernameAttr}=${ldapUserDN},${ldapUserOU},${ldapBaseDN}";
  autheliaHost = config.services.authelia.instances."${instance}".settings.server.host;
  autheliaPort = config.services.authelia.instances."${instance}".settings.server.port;
  redisUnixSocketPath = config.services.redis.servers."authelia-${instance}".unixSocket;
in
{

  sops = {
    secrets = {
      "authelia/jwt_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/session_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/storage_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/oidc_hmac_secret" = {
        owner = config.users.users."authelia-${instance}".name;
      };
      "authelia/oidc_issuer_private_key" = {
        format = "binary";
        sopsFile = ./secrets/issuer_private_key.pem;
        owner = config.users.users."authelia-${instance}".name;
      };
    };
  };

  services = {
    nginx = {
      upstreams = {
        "authelia" = {
          servers = {
            "${autheliaHost}:${toString autheliaPort}" = { };
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

    postgresql = {
      ensureDatabases = [
        dbName
      ];
      ensureUsers = [
        {
          name = dbUser;
          ensureDBOwnership = true;
        }
      ];
    };

    redis.servers."authelia-${instance}" = {
      enable = true;
      port = 0;
      user = config.users.users."authelia-${instance}".name;
      unixSocket = "/run/redis-authelia-${instance}/redis.sock";
    };

    authelia.instances."${instance}" = {
      enable = true;
      settings = {
        log = {
          level = "debug";
          format = "text";
        };
        session = {
          name = "session";
          domain = domainName;
          redis = {
            host = redisUnixSocketPath;
          };
        };
        access_control = {
          default_policy = "deny";
          rules = [
            {
              policy = "bypass";
              domain = "auth.${domainName}";
            }
            {
              policy = "bypass";
              domain = [ "*.${domainName}" ];
              resources = [
                "^/api([/?].*)?$"
              ];
            }
            {
              policy = "one_factor";
              domain = [
                "*.${domainName}"
              ];
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
          postgres = {
            host = dbHost;
            port = dbPort;
            database = dbName;
            password = dbUser;
            username = dbUser;
          };
        };
        notifier = {
          filesystem = {
            filename = "/var/lib/authelia-${instance}/notification.txt";
          };
        };
        default_2fa_method = "totp";
        identity_providers = {
          oidc = {
            clients = [
              {
                id = "jellyfin";
                secret = "$pbkdf2-sha512$310000$w8/7AXV6ljEACFLwkc.neQ$bMnyFnhUjuFjhKGw.awXKfK1EK6n9XS5P6RcywAbBxLhI6hcJqJ8jDCt3oOBp9YpaPCbNh3Sm23NCwJaUIci5w";
                description = "Jellyfin media server";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://jellyfin.${domainName}/sso/OID/redirect/authelia"
                ];
              }
              {
                id = "nextcloud";
                secret = "$pbkdf2-sha512$310000$uLH3iUPuaccs8Ps0L7e92A$ivBv3CRJZSuYX8ARlQGWlyyIlpcqcvQl518dOqxDQ5nMRKrOSYQmGkUAlSjF3Btklbs1V6CYSXfAwlIRYjqHFg";
                description = "Nextcloud";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://nextcloud.${domainName}/apps/user_oidc/code"
                ];
              }
              {
                id = "audiobookshelf";
                secret = "$pbkdf2-sha512$310000$CYG9RzneGw4EEojmAFaprA$CppTSc1wUVwvVtkD48.UFO7KPMAN9OlHIOMnuNeDAyvTSNXshShlcONmQinyd.D8DaOTGE0Sn.wWqEYRWnq9hg";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://audiobookshelf.${domainName}/auth/openid/callback"
                  "https://audiobookshelf.${domainName}/auth/openid/mobile-redirect"
                ];
              }
              {
                id = "paperless";
                secret = "$pbkdf2-sha512$310000$ylijOhbBagCwDiaNWPM2GA$mpdcyzbOgih92PY3WQO8x8BiZSLZu33uojolXe5hg/H.U71a.HGTY168YOcBz1TYeYqyCvY2s7jSW86Gb8qtUg";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://paperless.${domainName}/accounts/oidc/authelia/login/callback/"
                ];
              }
            ];
          };
        };
      };
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storage_secret".path;
        oidcHmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc_issuer_private_key".path;
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
