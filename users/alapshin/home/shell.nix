{ pkgs
, dotfileDir
, ...
}: {
  home.packages = with pkgs; [
    dog
    duf
    du-dust
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
      icons = true;
    };

    jq = {
      enable = true;
    };

    mpv = {
      enable = true;
    };

    navi = {
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
      settings = {
        format = "$all";
      } // builtins.fromTOML (builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/starship/starship/5d4007f5c179657611d7205e78cd8075eebbf532/docs/public/presets/toml/plain-text-symbols.toml";
        hash = "sha256-paZyZneqF2BgiGxHdX1RAAYdwSK6HtkB9e8GTGDNimU=";
      }));
    };

    tealdeer = {
      enable = false;
    };

    texlive = {
      enable = true;
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
          "adb"
          "docker"
          "docker-compose"
          "fzf"
          "git"
          "git-extras"
          "gradle"
          "man"
          "python"
          "pip"
          "ripgrep"
          "systemd"
        ];
      };
    };
  };
}
