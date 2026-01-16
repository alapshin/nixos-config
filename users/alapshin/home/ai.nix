{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
{
  programs = {
    mcp = {
      enable = true;
      servers = {
        context7 = {
          url = "https://mcp.context7.com/mcp";
        };
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
      enable = false;
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
        model = "openrouter/anthropic/claude-haiku-4.5";
        small_model = "openrouter/anthropic/claude-haiku-4.5";
        plugin = [
          "opencode-gemini-auth@1.3.7"
          "@mohak34/opencode-notifier@0.1.13"
        ];
        enabled_providers = [
          "google"
          "openrouter"
        ];
        provider = {
          google = {
            options = {
              projectId = "rich-phenomenon-443716-d6";
            };
          };
          openrouter = {
            options = {
              apiKey = "{file:~/.config/sops-nix/secrets/openrouter_api_key}";
            };
          };
        };
        permission = {
          "*" = "ask";
          "edit" = "allow";
          "glob" = "allow";
          "grep" = "allow";
          "list" = "allow";
          "read" = "allow";
          "write" = "allow";
          "patch" = "allow";
          "skill" = "ask";
          "question" = "allow";
          "todoread" = "allow";
          "todowrite" = "allow";
          "webfetch" = "ask";
          "bash" = {
            "*" = "ask";
            "uv *" = "ask";
            "nix *" = "ask";
            "npm *" = "ask";
            "pip *" = "ask";

            "ls *" = "allow";
            "cp *" = "allow";
            "mv *" = "ask";
            "rm *" = "ask";
            "rg *" = "allow";
            "sed *" = "allow";
            "grep *" = "allow";
            "find *" = "allow";
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
      agents = ./opencode/agent;
    };
  };
}
