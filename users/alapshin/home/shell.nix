{ pkgs
, dotfileDir
, ...
}: {
  home.shellAliases = {
    cat = "bat";
  };

  home.packages = with pkgs; [
    dog
    duf
    du-dust
    fd
    glow
    httpie
    ripgrep
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

    exa = {
      enable = true;
      package = pkgs.eza;
      enableAliases = true;
    };

    lsd = {
      enable = true;
    };

    navi = {
      enable = true;
      enableZshIntegration = true;
    };

    pandoc = {
      enable = true;
    };

    tealdeer.enable = true;

    tmux = {
      enable = true;
    };

    yt-dlp.enable = true;
  };

  programs.zsh = {
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
}
