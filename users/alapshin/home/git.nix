{ pkgs
, dotfileDir
, ...
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
          hyperlinks = true;
          line-numbers = true;
          side-by-side = true;
          features = "github";
        };
      };
      includes = [
        { path = /. + dotfileDir + "/gitconfig"; }
        {
          path = /. + dotfileDir + "/gitconfig-alar";
          condition = "gitdir:~/work/alar/";
        }
        {
          path = /. + dotfileDir + "/gitconfig-scalable";
          condition = "gitdir:~/work/scalable/";
        }
      ];
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          border = "rounded";
          expandFocusedSidePanel = true;
          theme = {
            selectedLineBgColor = [ "default" "bold" ];
            selectedRangeBgColor = [ "reverse" "bold" ];
          };
        };
        git = {
          paging = {
            useConfig = false;
            colorArg = "always";
            pager = "delta --paging=never";
          };
        };
        update = {
          method = "never";
        };
        promptToReturnFromSubprocess = false;
      };
    };
  };
}
