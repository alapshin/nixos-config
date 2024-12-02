{ pkgs, ... }:
{
  home.packages = with pkgs; [
    doggo
    duf
    dust
    fd
    glow
    sd
  ];

  programs = {
    atuin = {
      enable = true;
      settings = {
        style = "compact";
        auto_sync = false;
        update_check = false;
        inline_height = 10;
      };
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config = {
        style = "full";
        italic-text = "always";
      };
    };

    bottom = {
      enable = true;
    };

    broot = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    eza = {
      enable = true;
      icons = "auto";
      colors = "auto";
    };

    fastfetch = {
      enable = true;
    };

    gallery-dl = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    navi = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-your-shell = {
      enable = true;
      enableZshIntegration = true;
    };

    pandoc = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings =
        {
          format = "$all";
        }
        // builtins.fromTOML (
          builtins.readFile (
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/starship/starship/v1.19.0/docs/public/presets/toml/plain-text-symbols.toml";
              hash = "sha256-SRos2o/ZaBK3QOCumqopiFLKnK3mf5wehTkKWpO7OqQ=";
            }
          )
        );
    };

    tealdeer = {
      enable = false;
    };

    tmux = {
      enable = true;
    };

    yt-dlp.enable = true;

    zsh = {
      enable = true;
      dotDir = ".config/zsh";

      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      enableVteIntegration = true;
      autosuggestion.enable = true;

      history = {
        path = "$ZDOTDIR/.zsh_history";
        extended = true;
        expireDuplicatesFirst = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "docker"
          "docker-compose"
          "fzf"
          "git"
          "git-extras"
          "gradle"
          "man"
          "python"
          "pip"
          "systemd"
        ];
      };
    };
  };
}
