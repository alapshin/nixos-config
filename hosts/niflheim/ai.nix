{
  lib,
  pkgs,
  config,
  ...
}:
let
  ollamaHost = config.services.ollama.host;
  ollamaPort = config.services.ollama.port;
in
{
  sops = {
    secrets = {
      "open-webui/deepinfra_api_key" = { };
      "open-webui/oidc_client_secret" = { };
    };
    templates."open-webui.env".content = ''
      OPENAI_API_KEY=${config.sops.placeholder."open-webui/deepinfra_api_key"}
      OAUTH_CLIENT_SECRET=${config.sops.placeholder."open-webui/oidc_client_secret"}
    '';
  };

  services = {
    ollama = {
      enable = true;
    };

    open-webui = {
      enable = true;
      port = 8085;
      environment = {
        ENABLE_SIGNUP = "False";
        ENABLE_LOGIN_FORM = "False";
        ENABLE_OAUTH_SIGNUP = "True";
        OAUTH_CLIENT_ID = "open-webui";
        OPENID_PROVIDER_URL = "https://${config.domain.auth}/.well-known/openid-configuration";

        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ANONYMIZED_TELEMETRY = "False";

        OPENAI_API_BASE_URL = "https://api.deepinfra.com/v1/openai";
        OLLAMA_API_BASE_URL = "http://${ollamaHost}:${toString ollamaPort}";
      };
    };

    nginx-ext.applications."owui" = {
      auth = false;
      port = config.services.open-webui.port;
      proxyWebsockets = true;
    };
  };

  systemd.services = {
    open-webui.serviceConfig = {
      EnvironmentFile = config.sops.templates."open-webui.env".path;
    };
  };
}
