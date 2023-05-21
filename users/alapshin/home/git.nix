{
  pkgs,
  dotfileDir,
  ...
}: {

  home.shellAliases = {
    lg = "lazygit";
  };

  home.packages = with pkgs; [
    git-extras
    transcrypt
    git-filter-repo
  ];

  programs = {
    gh = {
      enable = true;
    };

    git = {
      enable = true;
      lfs = {
        enable = true;
      };
      delta = {
        enable = true;
        options = {
          light = true;
          line-numbers = true;
          features = "github";
        };
      };
      includes = [
        { path = /. + dotfileDir + "/gitconfig"; }
        { 
          path = /. + dotfileDir + "/gitconfig-alar"; 
          condition = "~/work/alar";
        }
      ];
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
          expandFocusedSidePanel = true;
        };
        git = {
          paging = {
            useConfig = false;
            colorArg = "always";
            pager = "delta --paging=never";
          };
        };
      };
    };
  };
}
