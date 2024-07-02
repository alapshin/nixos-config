{ lib
, pkgs
, config
, inputs
, domainName
, ...
}:
let
  instance = "main";
  dbName = "authelia-${instance}";
  dbUser = "authelia-${instance}";
  ldapHost = config.services.lldap.settings.ldap_host;
  ldapPort = config.services.lldap.settings.ldap_port;
  ldapBaseDN = config.services.lldap.settings.ldap_base_dn;
  ldapUserDN = config.services.lldap.settings.ldap_user_dn;
  ldapUserOU = "ou=people";
  ldapUsernameAttr = "uid";
  ldapFullUser = "${ldapUsernameAttr}=${ldapUserDN},${ldapUserOU},${ldapBaseDN}";
  autheliaPort = 8001;
  redisUnixSocketPath = config.services.redis.servers."authelia-${instance}".unixSocket;
in
{

  disabledModules = [
    "services/security/authelia.nix"
  ];
  imports = [
    "${inputs.authelia}/nixos/modules/services/security/authelia.nix"
  ];

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
    nginx = {
      upstreams = {
        "authelia" = {
          servers = {
            "localhost:${toString autheliaPort}" = { };
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
            };
            "/api/authz" = {
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
      package = pkgs.prs.authelia;

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
            };
          };
        };
        session = {
          redis = {
            host = redisUnixSocketPath;
          };
          cookies = [
            {
              domain = domainName;
              authelia_url = "https://auth.${domainName}";
            }
          ];
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
                # General API
                "^/api([/?].*)?$"
                # Navidrome API
                "^/rest([/?].*)?$"
                # Navidrome Share API
                "^/share([/?].*)?$"
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
            jwks = [
              {
                key_id = "main";
                key = ''{{ secret "/run/secrets/authelia/jwk_rsa_key.pem" | mindent 10 "|" | msquote }}'';
              }
            ];
            clients = [
              {
                client_id = "audiobookshelf";
                client_name = "Audiobookshelf";
                client_secret = "$pbkdf2-sha512$310000$CYG9RzneGw4EEojmAFaprA$CppTSc1wUVwvVtkD48.UFO7KPMAN9OlHIOMnuNeDAyvTSNXshShlcONmQinyd.D8DaOTGE0Sn.wWqEYRWnq9hg";
                require_pkce = true;
                pkce_challenge_method = "S256";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://audiobookshelf.${domainName}/auth/openid/callback"
                  "https://audiobookshelf.${domainName}/auth/openid/mobile-redirect"
                ];
              }
              {
                client_id = "grafana";
                client_name = "Grafana";
                client_secret = "$pbkdf2-sha512$310000$c6S3Q5j25GIJu2VBLf5VFg$S.j/GnNOjD40jpaSlizdi8gQnY2YXJusJcSOcIg8QgV8IkwAC9ILW1U21FrGMqePzfwoXYoYvgG.ZWk01MTo2Q";
                require_pkce = true;
                pkce_challenge_method = "S256";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://grafana.${domainName}/login/generic_oauth"
                ];
              }
              {
                client_id = "jellyfin";
                client_name = "Jellyfin";
                client_secret = "$pbkdf2-sha512$310000$w8/7AXV6ljEACFLwkc.neQ$bMnyFnhUjuFjhKGw.awXKfK1EK6n9XS5P6RcywAbBxLhI6hcJqJ8jDCt3oOBp9YpaPCbNh3Sm23NCwJaUIci5w";
                require_pkce = true;
                pkce_challenge_method = "S256";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://jellyfin.${domainName}/sso/OID/redirect/authelia"
                ];
                token_endpoint_auth_method = "client_secret_post";
              }
              {
                client_id = "nextcloud";
                client_name = "Nextcloud";
                client_secret = "$pbkdf2-sha512$310000$uLH3iUPuaccs8Ps0L7e92A$ivBv3CRJZSuYX8ARlQGWlyyIlpcqcvQl518dOqxDQ5nMRKrOSYQmGkUAlSjF3Btklbs1V6CYSXfAwlIRYjqHFg";
                require_pkce = true;
                pkce_challenge_method = "S256";
                authorization_policy = "one_factor";
                redirect_uris = [
                  "https://nextcloud.${domainName}/apps/oidc_login/oidc"
                ];
              }
              {
                client_id = "paperless";
                client_name = "Paperless";
                client_secret = "$pbkdf2-sha512$310000$ylijOhbBagCwDiaNWPM2GA$mpdcyzbOgih92PY3WQO8x8BiZSLZu33uojolXe5hg/H.U71a.HGTY168YOcBz1TYeYqyCvY2s7jSW86Gb8qtUg";
                require_pkce = true;
                pkce_challenge_method = "S256";
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
      LoadCredential = [
        "ldap_password:${config.sops.secrets."lldap/user_password".path}"
      ];
    };
  };
}
