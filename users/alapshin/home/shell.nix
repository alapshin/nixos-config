{ pkgs
, dotfileDir
, ...
}: {
  home.shellAliases = { };

  home.packages = with pkgs; [
    dog
    duf
    du-dust
    fd
    glow
    httpie
  ];

  services = {
    ssh-agent = {
      enable = true;
    };
  };

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
        theme = "GitHub";
        italic-text = "always";
      };
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
      enableAliases = true;
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

      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      enableVteIntegration = true;

      history = {
        path = "$ZDOTDIR/.zsh_history";
        extended = true;
        expireDuplicatesFirst = true;
      };

      plugins = [
        {
          name = "p10k";
          src = "${dotfileDir}";
          file = "p10k.zsh";
        }
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-syntax-highlighting-catpuccin";
          file = "themes/catppuccin_latte-zsh-syntax-highlighting.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "zsh-syntax-highlighting";
            rev = "06d519c20798f0ebe275fc3a8101841faaeee8ea";
            sha256 = "sha256-Q7KmwUd9fblprL55W0Sf4g7lRcemnhjh4/v+TacJSfo=";
          };
        }
      ];

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
