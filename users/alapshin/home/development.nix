{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages =
    with pkgs;
    [
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

      # Development
      scrcpy
    ]
    ++ (lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      jetbrains.datagrip
      jetbrains.idea-ultimate
      android-studio-stable-with-sdk
    ]);

  programs = {
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    gradle = {
      enable = true;
      home = ".local/share/gradle";
      settings = {
        "org.gradle.java.installations.paths" =
          "${pkgs.jdk8}/lib/openjdk,${pkgs.jdk17}/lib/openjdk,${pkgs.jdk21}/lib/openjdk";
      };
    };
  };
}
