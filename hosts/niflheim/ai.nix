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
      "open-webui/openai_api_key" = { };
      "open-webui/openrouter_api_key" = { };
      "open-webui/oidc_client_secret" = { };
    };

    templates."litellm.env".content = ''
      OPENROUTER_API_KEY=${config.sops.placeholder."open-webui/openrouter_api_key"}
    '';
    templates."open-webui.env".content = ''
      IMAGES_OPENAI_API_KEY=${config.sops.placeholder."open-webui/openai_api_key"}
      AUDIO_STT_OPENAI_API_KEY=${config.sops.placeholder."open-webui/openai_api_key"}
      AUDIO_TTS_OPENAI_API_KEY=${config.sops.placeholder."open-webui/openai_api_key"}
      OAUTH_CLIENT_SECRET=${config.sops.placeholder."open-webui/oidc_client_secret"}
    '';
  };

  services = {
    litellm = {
      enable = true;
      port = 10000;
      environment = {
        NO_DOCS = "True";
        NO_REDOC = "True";
        DISABLE_ADMIN_UI = "True";
      };
      environmentFile = config.sops.templates."litellm.env".path;
      settings = {
        model_list = [
          {
            model_name = "gpt-5";
            litellm_params = {
              model = "openrouter/openai/gpt-5";
            };
          }
          {
            model_name = "gpt-5-codex";
            litellm_params = {
              model = "openrouter/openai/gpt-5-codex";
            };
          }
          {
            model_name = "gpt-5-chat";
            litellm_params = {
              model = "openrouter/openai/gpt-5-chat";
            };
          }
          {
            model_name = "claude-haiku-4.5";
            litellm_params = {
              model = "openrouter/anthropic/claude-haiku-4.5";
            };
          }
          {
            model_name = "claude-sonnet-4";
            litellm_params = {
              model = "openrouter/anthropic/claude-sonnet-4";
            };
          }
          {
            model_name = "claude-sonnet-4.5";
            litellm_params = {
              model = "openrouter/anthropic/claude-sonnet-4.5";
            };
          }
          {
            model_name = "gemini-2.5-flash-preview";
            litellm_params = {
              model = "openrouter/google/gemini-2.5-flash-preview-09-2025";
            };
          }
          {
            model_name = "gemini-2.5-flash-lite-preview";
            litellm_params = {
              model = "openrouter/google/gemini-2.5-flash-lite-preview-09-2025";
            };
          }
        ];
      };
    };

    open-webui = {
      enable = true;
      port = 8085;
      environment = {
        ENV = "prod";
        ENABLE_PERSISTENT_CONFIG = "False";

        OFFLINE_MODE = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ANONYMIZED_TELEMETRY = "False";
        ENABLE_VERSION_UPDATE_CHECK = "False";
        SHOW_ADMIN_DETAILS = "False";
        ENABLE_EVALUATION_ARENA_MODELS = "False";

        ENABLE_SIGNUP = "False";
        ENABLE_LOGIN_FORM = "False";
        ENABLE_OAUTH_SIGNUP = "True";
        DEFAULT_USER_ROLE = "user";
        OAUTH_CLIENT_ID = "open-webui";
        OAUTH_SCOPES = "openid email profile groups";
        OAUTH_PROVIDER_NAME = "Authelia";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
        OAUTH_ROLES_CLAIM = "groups";
        OAUTH_ADMIN_ROLES = "open-webui-admin";
        OAUTH_ALLOWED_ROLES = "open-webui-user,open-webui-admin";
        ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
        WEBUI_URL = "https://owui.${config.services.webhost.basedomain}";
        OPENID_PROVIDER_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";

        DEFAULT_MODELS = "gpt-5-chat";
        OPENAI_API_BASE_URL = "http://localhost:${toString config.services.litellm.port}";

        # Redis
        # REDIS_URL = "unix://${redisSocket}";
        # Database
        DATABASE_URL = "postgresql:///${database}?host=/run/postgresql";

        # Audio
        AUDIO_STT_ENGINE = "openai";
        AUDIO_STT_MODEL = "gpt-4o-mini-transcribe";
        AUDIO_STT_OPENAI_API_BASE_URL = "https://api.openai.com/v1/";
        AUDIO_TTS_ENGINE = "openai";
        AUDIO_TTS_MODEL = "gpt-4o-mini-tts";
        AUDIO_TTS_VOICE = "ash";
        AUDIO_TTS_OPENAI_API_BASE_URL = "https://api.openai.com/v1/";
        # RAG
        RAG_EMBEDDING_ENGINE = "";
        RAG_EMBEDDING_MODEL = "sentence-transformers/all-mpnet-base-v2";
        CONTENT_EXTRACTION_ENGINE = "docling";
        DOCLING_OCR_ENGINE = "tesserocr";
        DOCLING_OCR_LANG = "eng,rus,spa,srp,srp_latn";
        DOCLING_SERVER_URL = "http://localhost:${toString config.services.docling-serve.port}";
        # Image Generation
        ENABLE_IMAGE_GENERATION = "True";
        IMAGE_SIZE = "1024x1024";
        IMAGE_GENERATION_ENGINE = "openai";
        IMAGE_GENERATION_MODEL = "dall-e-3";
        IMAGES_OPENAI_API_BASE_URL = "https://api.openai.com/v1/";
        # Web Search
        ENABLE_WEB_SEARCH = "True";
        WEB_SEARCH_ENGINE = "searxng";
        SEARXNG_QUERY_URL = "http://localhost:${toString config.services.searx.settings.server.port}/search?q=<query>";
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
      save = [
      ];
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
