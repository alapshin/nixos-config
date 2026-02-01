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
        ruff
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
      bun
      just
      tokei
      # HTTP API
      hurl
      xh
      mitmproxy

      # YAML
      yamlfmt

      # Markdown
      glow
      rumdl

      # Android
      scrcpy
      android-tools

      # JetBrains
      jetbrains-toolbox
      # Google Cloud CLI
      google-cloud-sdk

      sandbox-runtime
    ]
    ++ pythonPackages
    ++ (lib.lists.optionals (pkgs.stdenv.hostPlatform.isLinux && hostname == "desktop") [
      jetbrains.idea
      jetbrains.pycharm
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
  };
}
