{
  pkgs,
  dotfileDir,
  ...
}: {
  programs.bat.enable = true;
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.pandoc = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
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
        "httpie"
        "man"
        "python"
        "pip"
        "ripgrep"
        "systemd"
      ];
    };
  };
}
