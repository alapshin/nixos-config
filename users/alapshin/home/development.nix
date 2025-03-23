{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    tokei
    # HTTP API
    hurl
    xh

    # OpenAPI & Swagger
    redocly

    # YAML
    yamlfmt

    # AI
    aider-chat
  ];

  programs = {
    java = {
      enable = true;
      package = pkgs.jdk17;
    };
    gradle = {
      enable = true;
      home = ".local/share/gradle";
      settings = {
        "org.gradle.java.installations.paths" = "${pkgs.jdk8}/lib/openjdk,${pkgs.jdk17}/lib/openjdk";
      };
    };
  };
}
