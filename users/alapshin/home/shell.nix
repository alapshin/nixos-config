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
    httpie
    sd
    vivid
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
        theme = "catppuccin-latte";
        italic-text = "always";
      };
      themes = {
        "catppuccin-latte" = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-latte.tmTheme";
        };
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

      initExtra = ''
        export LS_COLORS="$(vivid generate catppuccin-latte)"
      '';

      plugins = [
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

    starship =
      let
        flavour = "latte"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
      in
      {
        enable = true;
        enableZshIntegration = true;
        settings = {
          # Other config here
          format = "$all"; # Remove this line to disable the default prompt format
          palette = "catppuccin_${flavour}";
        }
        // builtins.fromTOML (builtins.readFile (pkgs.fetchurl {
          url = "https://starship.rs/presets/toml/nerd-font-symbols.toml";
          hash = "sha256-BVe5JMSIa3CoY2Wf9pvcF1EUtDVCWCLhW3IyKuwfHug=";
        }))
        // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "starship";
            rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
            sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
          } + /palettes/${flavour}.toml));
      };
  };
}
