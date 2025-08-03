{
  lib,
  pkgs,
  config,
  ...
}:
let
  user = "open-webui";
  database = "open-webui";
  ollamaHost = config.services.ollama.host;
  ollamaPort = config.services.ollama.port;
  redisSocket = config.services.redis.servers."open-webui".unixSocket;
in
{
  sops = {
    secrets = {
      "open-webui/openrouter_api_key" = { };
      "open-webui/oidc_client_secret" = { };
    };
    templates."open-webui.env".content = ''
      OPENAI_API_KEY=${config.sops.placeholder."open-webui/openrouter_api_key"}
      OAUTH_CLIENT_SECRET=${config.sops.placeholder."open-webui/oidc_client_secret"}
    '';
  };

  services = {
    open-webui = {
      enable = true;
      port = 8085;
      environment = {
        ENABLE_PERSISTENT_CONFIG = "False";

        OFFLINE_MODE = "True";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ANONYMIZED_TELEMETRY = "False";
        ENABLE_VERSION_UPDATE_CHECK = "False";

        ENABLE_SIGNUP = "False";
        ENABLE_LOGIN_FORM = "False";
        ENABLE_OAUTH_SIGNUP = "True";
        OAUTH_CLIENT_ID = "open-webui";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
        OAUTH_ROLES_CLAIM = "groups";
        ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
        OPENID_PROVIDER_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";

        REDIS_URL = "unix://${redisSocket}";
        WEBUI_URL = "https://owui.${config.services.webhost.basedomain}";
        DATABASE_URL = "postgresql:///${database}?host=/run/postgresql";

        OPENAI_API_BASE_URL = "https://openrouter.ai/api/v1";
      };
      environmentFile = config.sops.templates."open-webui.env".path;
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

    redis.servers."open-webui" = {
      enable = true;
      port = 0;
      user = user;
    };

    webhost.applications."owui" = {
      auth = false;
      port = config.services.open-webui.port;
    };

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "open-webui";
              client_name = "Open WebUI";
              client_secret = "$pbkdf2-sha512$310000$b6mTChIj/dqB1tgrNWpJCA$L0o17Sn8c2U2G9U3AHmOsI03TsHIwnU9rjiqvw2hEcl/lcbc6r48cBS4aU/Bq4g9PYF9lihl3o2fbhlIOE7fEA";
              authorization_policy = "one_factor";
              scopes = [
                "openid"
                "email"
                "profile"
                "groups"
              ];
              redirect_uris = [ "https://owui.${config.services.webhost.basedomain}/oauth/oidc/callback" ];
            }
          ];
        };
      };
    };
  };

  systemd.services = {
    open-webui.serviceConfig = {
      User = user;
    };
  };

  users.users."${user}" = {
    group = user;
    isSystemUser = true;
  };
  users.groups."${user}" = { };
}
