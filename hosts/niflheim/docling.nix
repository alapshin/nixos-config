{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = config.services.docling-serve.port;
in
{
  services = {
    docling-serve = {
      enable = false;
      package = pkgs.docling-serve.override {
        withUI = true;
        withTesserocr = true;
      };
      environment = {
        DOCLING_SERVE_ENABLE_UI = "True";
      };
    };

    webhost.applications."docling" = {
      auth = true;
      inherit port;
    };
  };

  virtualisation.oci-containers.containers."docling-serve" = {
    image = "docling-project/docling-serve-cpu:v1.9.0";
    ports = [
      "127.0.0.1:${builtins.toString port}:${builtins.toString port}/tcp"
    ];
    log-driver = "journald";
    environment = {
      DOCLING_SERVE_ENABLE_UI = "1";
    };
  };
}
