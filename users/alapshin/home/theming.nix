{ pkgs
, config
, ...
}:
let
  accent = "sky";
  flavor = "latte";
  catppuccin = pkgs.catppuccin.override { inherit accent; variant = flavor; };
in
{
  programs = {
    bat = {
      config = {
        theme = "catppuccin-${flavor}";
      };
      themes = {
        "catppuccin-${flavor}" = {
          src = catppuccin;
          file = "bat/Catppuccin-${flavor}.tmTheme";
        };
      };
    };

    bottom = {
      settings = { } // builtins.fromTOML (builtins.readFile "${catppuccin}/bottom/${flavor}.toml");
    };

    git = {
      delta = {
        options = {
          features = "catppuccin-${flavor}";
        };
      };
    };

    starship = {
      settings = {
        palette = "catppuccin_${flavor}";
      } // builtins.fromTOML (builtins.readFile "${catppuccin}/starship/${flavor}.toml");
    };

    zsh = {
      initExtra = ''
        export LS_COLORS="$(vivid generate catppuccin-latte)"
      '';

      plugins = [
        {
          name = "zsh-syntax-highlighting-catpuccin";
          file = "themes/catppuccin_${flavor}-zsh-syntax-highlighting.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "zsh-syntax-highlighting";
            rev = "06d519c20798f0ebe275fc3a8101841faaeee8ea";
            sha256 = "sha256-Q7KmwUd9fblprL55W0Sf4g7lRcemnhjh4/v+TacJSfo=";
          };
        }
      ];
    };
  };

  home.packages = with pkgs; [
    vivid
    catppuccin
    (catppuccin-kde.override {
      accents = [ accent ];
      flavour = [ flavor ];
    })
    (catppuccin-papirus-folders.override { inherit accent flavor; })
  ];

  home.sessionVariables = {
    LG_CONFIG_FILE = "${config.xdg.configHome}/lazygit/config.yml,${catppuccin}/lazygit/themes-mergable/${flavor}-${accent}.yml";
  };

}
