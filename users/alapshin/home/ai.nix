{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
{
  sops = {
    secrets = {
      "opencode_api_key" = {
        path = "%r/opencode_api_key";
      };
      "openrouter_api_key" = {
        path = "%r/openrouter_api_key";
      };
    };
  };

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
        model = "openrouter/moonshotai/kimi-k2.5";
        small_model = "openrouter/moonshotai/kimi-k2.5";
        plugin = [
          "@tarquinen/opencode-dcp@1.2.8"
          "@mohak34/opencode-notifier@0.1.15"
        ];
        enabled_providers = [
          "opencode"
          "openrouter"
        ];
        provider = {
          opencode = {
            options = {
              apiKey = "{file:~/.config/sops-nix/secrets/opencode_api_key}";
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
