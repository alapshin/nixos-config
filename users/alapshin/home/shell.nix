{
  pkgs,
  config,
  dotfileDir,
  ...
}:
{
  home.packages = with pkgs; [
    coreutils
    doggo
    duf
    dust
    fd
    gnused
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
        enable = pkgs.stdenv.hostPlatform.isLinux;
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
      # Additional abbreviations from oh-my-zsh git plugin that are missing from fish's git plugin
      shellAbbrs = {
        gpr = "git pull --rebase";
        gpd = "git push --dry-run";
        gpf = "git push --force-with-lease --force-if-includes";
      };
      functions = {
        sshpool = ''
          if test (count $argv) -eq 2
            ssh -t -o "RemoteCommand=shpool attach -f $argv[2]" "$argv[1]"
          else
            echo "usage: sshpool <remote-machine> <session-name>" >&2; return 1
          end
        '';
      };
    };

    gallery-dl.enable = false;

    ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
      settings = {
        auto-update = "off";
        # Enable newline via shift-enter
        # See https://github.com/ghostty-org/ghostty/discussions/7780
        keybind = "shift+enter=text:\n";
        font-size = 12;
        font-family = "JetBrainsMono Nerd Font Mono";
      };
    };

    jq.enable = true;
    navi.enable = true;
    nix-your-shell.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    ripgrep-all.enable = true;

    starship = {
      enable = true;
      settings = {
        format = "$all";
      };
      presets = [
        "plain-text-symbols"
      ];
    };

    tealdeer.enable = false;
    tirith.enable = true;
    yazi = {
      enable = true;
      shellWrapperName = "y";
    };
    yt-dlp.enable = true;

    wezterm = {
      enable = true;
      extraConfig = builtins.readFile "${dotfileDir}/wezterm/wezterm.lua";
    };

    zoxide.enable = true;

    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";

      enableCompletion = !pkgs.stdenv.hostPlatform.isDarwin;
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

      initContent = ''
        sshpool() {
          if [ $# -eq 2 ]; then
            ssh -t -o "RemoteCommand=shpool attach -f ''\${2}" "''\${1}"
          else
            echo "usage: sshpool <remote-machine> <session-name>" >&2; return 1
          fi
        }
      '';
    };
  };

  xdg.configFile = {
  };
}
