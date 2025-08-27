{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  hostname = osConfig.networking.hostName;
in
{
  home.packages =
    with pkgs;
    [
      tokei
      # HTTP API
      # hurl
      xh
      mitmproxy

      # OpenAPI & Swagger
      redocly

      # YAML
      yamlfmt

      # AI
      # aider-chat

      # Development
      scrcpy

      jetbrains.idea-ultimate
    ]
    ++ (lib.lists.optionals
      (pkgs.stdenv.hostPlatform.isLinux && osConfig.networking.hostName == "desktop")
      [
        code-cursor-fhs
        android-studio-stable-with-sdk
      ]
    );

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
