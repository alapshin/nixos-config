{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  hostname = osConfig.networking.hostName;
  pythonPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        coverage
        ipython
        pytest
        pytest-cov
        pytest-mock
        requests

        fava
        autobean
        beancount
      ]
    ))
  ];
in
{
  home.packages =
    with pkgs;
    [
      tokei
      # HTTP API
      hurl
      xh
      mitmproxy

      # OpenAPI & Swagger
      redocly

      # YAML
      yamlfmt

      # Android
      scrcpy

      # JetBrains
      jetbrains-toolbox
    ]
    ++ pythonPackages
    ++ (lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && hostname == "desktop") [
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
        "org.gradle.java.installations.paths" = "${pkgs.jdk8.home},${pkgs.jdk17.home},${pkgs.jdk21.home}";
      };
    };
    uv = {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system";
      };
    };

    aider-chat = {
      enable = true;
      settings = {
        # Git
        auto-commits = false;
        # Upgrading
        check-update = false;
      };
    };
    claude-code = {
      enable = true;
    };
    gemini-cli = {
      enable = true;
    };
  };
}
