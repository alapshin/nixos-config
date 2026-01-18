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
        model = "google/antigravity-gemini-3-pro";
        small_model = "google/antigravity-gemini-3-flash";
        plugin = [
          "opencode-antigravity-auth@1.3.0"
          "@mohak34/opencode-notifier@0.1.13"
        ];
        enabled_providers = [
          "google"
          "opencode"
          "openrouter"
        ];
        provider = {
          google = {
            models = {
              "gemini-2.5-flash" = {
                name = "Gemini 2.5 Flash (Gemini CLI)";
                limit = {
                  output = 65536;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-2.5-pro" = {
                name = "Gemini 2.5 Pro (Gemini CLI)";
                limit = {
                  output = 65536;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-3-flash-preview" = {
                name = "Gemini 3 Flash Preview (Gemini CLI)";
                limit = {
                  output = 65536;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "gemini-3-pro-preview" = {
                name = "Gemini 3 Pro Preview (Gemini CLI)";
                limit = {
                  output = 65535;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "antigravity-gemini-3-pro" = {
                name = "Gemini 3 Pro (Antigravity)";
                limit = {
                  output = 65535;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingLevel = "low";
                  };
                  high = {
                    thinkingLevel = "high";
                  };
                };
              };
              "antigravity-gemini-3-flash" = {
                name = "Gemini 3 Flash (Antigravity)";
                limit = {
                  output = 65536;
                  context = 1048576;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  minimal = {
                    thinkingLevel = "minimal";
                  };
                  low = {
                    thinkingLevel = "low";
                  };
                  medium = {
                    thinkingLevel = "medium";
                  };
                  high = {
                    thinkingLevel = "high";
                  };
                };
              };
              "antigravity-claude-sonnet-4-5" = {
                name = "Claude Sonnet 4.5 (Antigravity)";
                limit = {
                  output = 64000;
                  context = 200000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
              };
              "antigravity-claude-sonnet-4-5-thinking" = {
                name = "Claude Sonnet 4.5 Thinking (Antigravity)";
                limit = {
                  output = 64000;
                  context = 200000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingConfig = {
                      thinkingBudget = 8192;
                    };
                  };
                  max = {
                    thinkingConfig = {
                      thinkingBudget = 32768;
                    };
                  };
                };
              };
              "antigravity-claude-opus-4-5-thinking" = {
                name = "Claude Opus 4.5 Thinking (Antigravity)";
                limit = {
                  output = 64000;
                  context = 200000;
                };
                modalities = {
                  input = [
                    "text"
                    "image"
                    "pdf"
                  ];
                  output = [ "text" ];
                };
                variants = {
                  low = {
                    thinkingConfig = {
                      thinkingBudget = 8192;
                    };
                  };
                  max = {
                    thinkingConfig = {
                      thinkingBudget = 32768;
                    };
                  };
                };
              };
            };
          };
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
