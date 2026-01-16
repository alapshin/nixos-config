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
