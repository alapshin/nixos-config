{ pkgs, ... }:
{
  home.packages = with pkgs; [
    doggo
    duf
    dust
    fd
    glow
    sd
    trippy
  ];

  programs = {
    atuin = {
      enable = true;
      settings = {
        style = "compact";
        auto_sync = false;
        inline_height = 10;
        update_check = false;
      };
      daemon = {
        enable = true;
      };
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
    };

    fzf = {
      enable = true;
      defaultOptions = [
        "--style=full"
        "--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39"
        "--color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78"
        "--color=marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
        "--color=selected-bg:#bcc0cc"
        "--color=border:#ccd0da,label:#4c4f69"
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
    };

    nix-your-shell = {
      enable = true;
    };

    pandoc = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    ripgrep-all = {
      enable = true;
    };

    starship = {
      enable = true;
      settings =
        {
          format = "$all";
        }
        // builtins.fromTOML (
          builtins.readFile (
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/starship/starship/v1.22.1/docs/public/presets/toml/plain-text-symbols.toml";
              hash = "sha256-cJht5h+MlMhYM4PZXW8hidnkap+xOeOgj5sfEWSpSno=";
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
        highlighters = [
          "main"
          "cursor"
          "brackets"
        ];
      };
      enableVteIntegration = true;
      autosuggestion.enable = true;

      history = {
        path = "$ZDOTDIR/.zsh_history";
        extended = true;
        ignoreAllDups = true;
        expireDuplicatesFirst = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "fzf"
          "gh"
          "git"
          "git-extras"
          "gradle"
          "man"
          "podman"
          "swiftpm"
          "systemd"
        ];
      };
    };
  };
}
