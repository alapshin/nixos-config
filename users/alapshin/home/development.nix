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
      # Google Cloud CLI
      google-cloud-sdk
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
        "org.gradle.java.home" = config.programs.java.package.home;
        "org.gradle.java.installations.auto-detect" = false;
        "org.gradle.java.installations.auto-download" = false;
        "org.gradle.java.installations.paths" = config.programs.java.package.home;
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
      enable = false;
      settings = {
        # Git
        auto-commits = false;
        # Upgrading
        check-update = false;
      };
    };
    codex = {
      enable = true;
    };
    claude-code = {
      enable = true;
    };
    gemini-cli = {
      enable = true;
    };
  };
}
