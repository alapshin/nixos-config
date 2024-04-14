{ pkgs
, config
, dotfileDir
, ...
}: {
  home = {
    packages = with pkgs; [
      git-extras
      transcrypt
      git-filter-repo
    ];

    shellAliases = {
      lg = "lazygit";
    };
  };

  programs = {
    gh = {
      enable = true;
    };

    git = {
      enable = true;
      lfs = {
        enable = true;
      };
      signing = {
        key = null;
        signByDefault = true;
      };
      delta = {
        enable = true;
        options = {
          light = true;
          navigate = true;
          hyperlinks = true;
          line-numbers = true;
          side-by-side = true;
        };
      };
      includes = [
        { path = /. + dotfileDir + "/git/config"; }
        {
          path = /. + dotfileDir + "/git/config-alar";
          condition = "gitdir:~/work/alar/";
        }
        {
          path = /. + dotfileDir + "/git/config-scalable";
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
