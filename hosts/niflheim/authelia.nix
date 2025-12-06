{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  instance = "main";
  ldapHost = config.services.lldap.settings.ldap_host;
  ldapPort = config.services.lldap.settings.ldap_port;
  ldapBaseDN = config.services.lldap.settings.ldap_base_dn;
  ldapUserDN = config.services.lldap.settings.ldap_user_dn;
  ldapUserOU = "ou=people";
  ldapUsernameAttr = "uid";
  ldapFullUser = "${ldapUsernameAttr}=${ldapUserDN},${ldapUserOU},${ldapBaseDN}";
  databaseName = "authelia-${instance}";
  databaseUser = "authelia-${instance}";
  autheliaPort = 8001;
  autheliaUser = config.services.authelia.instances."${instance}".user;
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
      "authelia/jwk_rsa_key.pem" = {
        format = "binary";
        sopsFile = ./secrets/authelia/jwk_rsa_key.pem;
        owner = config.users.users."authelia-${instance}".name;
      };
    };
  };

  services = {
    caddy = {
      virtualHosts."${config.services.webhost.authdomain}" = {
        extraConfig = ''
          reverse_proxy localhost:${toString autheliaPort}
        '';
      };
    };

    postgresql = {
      ensureDatabases = [ databaseName ];
      ensureUsers = [
        {
          name = databaseUser;
          ensureDBOwnership = true;
        }
      ];
    };

    redis.servers."authelia-${instance}" = {
      enable = true;
      port = 0;
      user = autheliaUser;
      unixSocket = "/run/redis-authelia-${instance}/redis.sock";
    };

    authelia.instances."${instance}" = {
      enable = true;

      settings = {
        log = {
          level = "debug";
          format = "text";
        };
        server = {
          address = "tcp://localhost:${toString autheliaPort}";
          endpoints = {
            authz = {
              auth-request = {
                implementation = "AuthRequest";
              };
              forward-auth = {
                implementation = "ForwardAuth";
              };
            };
          };
        };
        session = {
          redis = {
            host = redisUnixSocketPath;
          };
          cookies = [
            {
              domain = config.services.webhost.basedomain;
              authelia_url = "https://${config.services.webhost.authdomain}";
            }
          ];
        };
        access_control = {
          default_policy = "deny";
          rules = [
            {
              policy = "bypass";
              domain = config.services.webhost.authdomain;
            }
            {
              policy = "bypass";
              domain = [ "*.${config.services.webhost.basedomain}" ];
              resources = [
                # General API
                "^/api([/?].*)?$"
                # Calibre OPDS API
                "^/opds([/?].*)?$"
              ];
            }
            {
              policy = "bypass";
              domain = [ "rssbridge.${config.services.webhost.basedomain}" ];
              query = [
                {
                  key = "action";
                  operator = "equal";
                  value = "display";
                }
              ];
            }
            {
              policy = "one_factor";
              domain = [ "*.${config.services.webhost.basedomain}" ];
            }
          ];
        };
        authentication_backend = {
          ldap = {
            address = "ldap://${ldapHost}:${toString ldapPort}";
            user = ldapFullUser;
            base_dn = ldapBaseDN;
            groups_filter = "(member={dn})";
            additional_groups_dn = "ou=groups";
            users_filter = "(&({username_attribute}={input})(objectClass=person))";
            additional_users_dn = ldapUserOU;
            attributes = {
              mail = "mail";
              username = ldapUsernameAttr;
              display_name = "displayName";
            };
          };
        };
        storage = {
          postgres = {
            address = "unix:///run/postgresql";
            database = databaseName;
            password = databaseUser;
            username = databaseUser;
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
            jwks = [
              {
                key_id = "main";
                key = ''{{ secret "/run/secrets/authelia/jwk_rsa_key.pem" | mindent 10 "|" | msquote }}'';
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
        oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/jwk_rsa_key.pem".path;
      };
    };
  };

  systemd.services."authelia-${instance}" = {
    requires = [
      "lldap.service"
      "postgresql.service"
      "redis-authelia-${instance}.service"
    ];
    environment = {
      X_AUTHELIA_CONFIG_FILTERS = "template";
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldap_password";
    };
    serviceConfig = {
      LoadCredential = [ "ldap_password:${config.sops.secrets."lldap/user_password".path}" ];
    };
  };
}
