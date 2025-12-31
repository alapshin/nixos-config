{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 8040;
  user = "pinepods";
  database = "pinepods";
  redisPort = 6380;
  redisName = "pinepods";
in
{
  sops = {
    secrets = {
      "pinepods/admin_password" = { };
      "pinepods/database_password" = {
        owner = "postgres";
      };
      "pinepods/oidc_client_secret" = { };
    };
    templates."pinepods.env".content = ''
      EMAIL=admin@${config.services.webhost.basedomain}
      USERNAME=admin
      FULLNAME=admin
      PASSWORD=${config.sops.placeholder."pinepods/admin_password"}
      DB_PASSWORD=${config.sops.placeholder."pinepods/database_password"}
    '';
    templates."pinepods-oidc.env".content = ''
      OIDC_PROVIDER_NAME=Authelia
      OIDC_CLIENT_ID=pinepods
      OIDC_CLIENT_SECRET=${config.sops.placeholder."pinepods/oidc_client_secret"}
      OIDC_TOKEN_URL=https://${config.services.webhost.authdomain}/oauth2/token
      OIDC_USER_INFO_URL=https://${config.services.webhost.authdomain}/oauth2/userinfo
      OIDC_AUTHORIZATION_URL=https://${config.services.webhost.authdomain}/oauth2/authorize
      OIDC_SCOPE="openid email profile groups"
      OIDC_EMAIL_CLAIM=email
      OIDC_ROLES_CLAIM=groups
      OIDC_USERNAME_CLAIM=preferred_username
      OIDC_USER_ROLE=pinepods-user
      OIDC_ADMIN_ROLE=pinepods-admin
    '';
  };
  services = {
    redis.servers."${redisName}" = {
      enable = true;
      user = user;
      port = redisPort;
    };

    postgresql = {
      ensureDatabases = [ database ];
      ensureUsers = [
        {
          name = user;
          ensureDBOwnership = true;
        }
      ];
    };

    webhost.applications."pinepods" = {
      auth = false;
      inherit port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "pinepods";
              client_name = "PinePods";
              client_secret = "$pbkdf2-sha512$310000$/LuusHBezJ3CO8xqtQjiwg$wHtf14Z0FYB2erhUAsJXVLXUHwwQKSDFIm/fdH80v41R2bzw1oXqA4b1tEymaeYDI1c0VxMBYkXZvFnCdHqQFw";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://pinepods.${config.services.webhost.basedomain}/api/auth/callback"
              ];
            }
          ];
        };
      };
    };
  };

  users.users."${user}" = {
    uid = 300;
    group = user;
    isSystemUser = true;
  };
  users.groups."${user}" = {
    gid = 300;
  };


  systemd.tmpfiles.settings = {
    "20-pinepods" = {
      "/var/lib/pinepods/downloads" = {
        d = {
          mode = "0775";
          user = user;
          group = "media";
        };
      };
      "/var/lib/pinepods/backups" = {
        d = {
          mode = "0775";
          user = user;
          group = "media";
        };
      };
    };
  };

  systemd.services.postgresql-setup.postStart = pkgs.lib.mkAfter ''
    password=$(cat ${config.sops.secrets."pinepods/database_password".path})
    psql -tAc "ALTER USER ${user} WITH PASSWORD '$password';"
  '';

  virtualisation.oci-containers.containers."pinepods" = {
    image = "madeofpendletonwool/pinepods:0.8.2";
    extraOptions = [ "--network=host" ];
    # ports = [
    #   "${toString port}:${toString port}"
    # ];
    volumes = [
      "/var/lib/pinepods/backups:/opt/pinepods/backups"
      "/var/lib/pinepods/downloads:/opt/pinepods/downloads"
    ];
    environment = {
      DEBUG_MODE = "true";
      HOSTNAME = "https://pinepods:${config.services.webhost.basedomain}";

      PUID = toString config.users.users."${user}".uid;
      PGID = toString config.users.groups."${user}".gid;

      DB_HOST = "localhost";
      DB_TYPE = "postgresql";
      DB_PORT = toString config.services.postgresql.settings.port;
      DB_USER = user;
      DB_NAME = database;

      VALKEY_HOST = "localhost";
      VALKEY_PORT = toString config.services.redis.servers."${redisName}".port;

      PEOPLE_API_URL = "https://people.pinepods.online";
      SEARCH_API_URL = "https://search.pinepods.online/api/search";
    };
    environmentFiles = [
      config.sops.templates."pinepods.env".path
      config.sops.templates."pinepods-oidc.env".path
    ];
  };
}
