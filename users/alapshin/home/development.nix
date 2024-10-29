{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # HTTP API
    bruno
    hurl
    xh

    # OpenAPI & Swagger
    redocly

    # YAML
    yamlfmt

    # AI
    # aider-chat
    whisper-ctranslate2
  ];
}
