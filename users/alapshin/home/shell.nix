{ pkgs, dotfileDir, ... }:
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
      settings = {
        network_use_binary_prefix = true;
      };
    };

    carapace.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      icons = "auto";
      colors = "auto";
    };

    fastfetch.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      plugins = [
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
      ];
    };

    gallery-dl.enable = true;
    jq.enable = true;
    navi.enable = true;
    nix-your-shell.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    ripgrep-all.enable = true;

    starship = {
      enable = true;
      settings =
        {
          format = "$all";
        }
        // builtins.fromTOML (
          builtins.readFile (
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/starship/starship/v1.23.0/docs/public/presets/toml/plain-text-symbols.toml";
              hash = "sha256-1LnKMIx0HrmULhcLxfu5VImuHvOAWTntVDjtI+Y4sjY=";
            }
          )
        );
    };

    tealdeer.enable = true;
    television.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;

    wezterm = {
      enable = true;
      extraConfig = builtins.readFile "${dotfileDir}/wezterm/wezterm.lua";
    };

    zellij = {
      enable = true;
      settings = {
        ui = {
          pane_frames = {
            rounded_corners = true;
          };
        };
      };
    };
    zoxide.enable = true;

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
