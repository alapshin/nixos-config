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
    ]
    ++ (lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && hostname != "altdesk") [
      jetbrains.idea-ultimate
    ])
    ++ (lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && hostname == "desktop") [
      code-cursor-fhs
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
        "org.gradle.java.installations.paths" = "${pkgs.jdk8.home},${pkgs.jdk17.home},${pkgs.jdk21.home}";
      };
    };
  };
}
