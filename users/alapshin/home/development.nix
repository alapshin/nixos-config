{
  lib,
  pkgs,
  config,
  ...
}:
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
    aider-chat
    # whisper-ctranslate2
  ];

  programs.gradle = {
    enable = true;
    home = ".local/share/gradle";
    settings = {
      "org.gradle.java.installations.paths" = "${pkgs.jdk17}/lib/openjdk";
    };
  };
}
