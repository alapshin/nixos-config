{
  pkgs,
  dotfileDir,
  ...
}: {
  programs = {
    gh = {
      enable = true;
    };

    git = {
      enable = true;
      lfs = {
        enable = true;
      };
    };

    gitui = {
      enable = true;
      keyConfig = /. + dotfileDir + "/gitui/key_bindings.ron";
    };

    lazygit = {
      enable = true;
      settings = {
        gui= {
          border = "rounded";
          theme = {
            lightTheme = true;
          };
        };
      };
    };
  };

  home.shellAliases = {
    lg = "lazygit";
  };
  home.packages = with pkgs; [
    git-extras
    transcrypt
    git-filter-repo
  ];
}
