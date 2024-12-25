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
    };
    templates."open-webui.env".content = ''
      OPENAI_API_KEY=${config.sops.placeholder."open-webui/deepinfra_api_key"}
    '';
  };

  services = {
    ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0";
    };

    open-webui = {
      enable = false;
      port = 8085;
      environment = {
        WEBUI_AUTH = "False";

        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ANONYMIZED_TELEMETRY = "False";

        OPENAI_API_BASE_URL = "https://api.deepinfra.com/v1/openai";

        OLLAMA_API_BASE_URL = "http://${ollamaHost}:${toString ollamaPort}";

      };
    };
  };

  systemd.services = {
    open-webui.serviceConfig = {
      EnvironmentFile = config.sops.templates."open-webui.env".path;
    };
  };

  environment.systemPackages = with pkgs; [
    clinfo
    rocmPackages.rocminfo
  ];
}
