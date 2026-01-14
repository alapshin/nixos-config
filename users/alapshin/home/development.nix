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
      jetbrains.pycharm
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
      enable = false;
    };
    claude-code = {
      enable = true;
      settings = {
        model = "haiku";
        apiKeyHelper = "cat ~/.config/sops-nix/secrets/openrouter_api_key";
        env = {
          ANTHROPIC_API_KEY = "";
          ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
        };
        sandbox = {
          enabled = true;
        };
      };
    };
    gemini-cli = {
      enable = false;
    };
    opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        autoupdate = false;
        theme = "catppuccin";
        model = "openrouter/anthropic/claude-sonnet-4.5";
        small_model = "openrouter/anthropic/claude-haiku-4.5";
        enabled_providers = [
          "openrouter"
        ];
        provider = {
          openrouter = {
            options = {
              apiKey = "{file:~/.config/sops-nix/secrets/openrouter_api_key}";
            };
          };
        };
        formatter = {
          rumdl = {
            command = [
              "rumdl"
              "$FILE"
            ];
            extensions = [ ".md" ];
          };
        };
      };
      agents = {
        code-reviewer = ''
          ---
          mode: subagent
          model: openrouter/anthropic/claude-sonnet-4.5
          temperature: 0.1
          tools:
            bash: false
            edit: false
            write: false
          description: Reviews code for quality and best practices
          ---
          You are in code review mode.

          Focus on:

            - Code quality
            - Best practices
            - Security considerations
            - Performance implications
            - Potential bugs and edge cases

          Provide constructive feedback without making direct changes.
        '';
        documentation-writer = ''
          ---
          mode: subagent
          model: openrouter/anthropic/claude-sonnet-4.5
          tools:
            bash: false
          description: Writes and maintains project documentation
          ---
          You are a technical writer. Create clear, comprehensive documentation.

          Focus on:

            - Proper structure
            - Clear explanations
            - Code and usage examples
            - User-friendly but professional language
        '';
      };
    };
  };
}
