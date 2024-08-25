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

        OLLAMA_API_BASE_URL = "http://${ollamaHost}:${toString ollamaPort}";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    clinfo
    nvtopPackages.amd
    rocmPackages.rocminfo
  ];
}
