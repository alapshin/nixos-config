{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # HTTP API
    hurl
    xh

    # OpenAPI & Swagger
    redocly

    # YAML
    yamlfmt

    # AI
    # aider-chat
    # whisper-ctranslate2
  ];
}
