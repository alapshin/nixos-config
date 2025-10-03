{
  lib,
  pkgs,
  config,
  ...
}:
{
  services = {
    docling-serve = {
      enable = true;
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
      port = config.services.docling-serve.port;
    };
  };
}
