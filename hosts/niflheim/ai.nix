{ lib
, pkgs
, config
, ...
}:
let
  ollamaHost = config.services.ollama.host;
  ollamaPort = config.services.ollama.port;
in
{
  sops = {
    secrets = {
      "open-webui/oidc_client_secret" = { };
    };
    templates."open-webui.env".content = ''
      OAUTH_CLIENT_SECRET=${config.sops.placeholder."open-webui/oidc_client_secret"}
    '';
  };

  services = {
    ollama = {
      enable = true;
      loadModels = [
        "llama3.1:8b"
        "llama3.1:70b"
      ];
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

        OLLAMA_API_BASE_URL = "http://${ollamaHost}:${toString ollamaPort}";
      };
    };

    nginx-ext.applications."owui" = {
      auth = false;
      port = config.services.open-webui.port;
    };
  };

  systemd.services = {
    ollama.serviceConfig = {
      TimeoutStartSec = "15m";
    };
    open-webui.serviceConfig = {
      EnvironmentFile = config.sops.templates."open-webui.env".path;
    };
  };
}
