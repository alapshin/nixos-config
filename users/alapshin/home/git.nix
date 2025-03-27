{
  pkgs,
  config,
  dotfileDir,
  ...
}:
{
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
      settings = {
        git_protocol = "ssh";
      };
    };
    gh-dash = {
      enable = true;
    };

    git = {
      enable = true;
      ignores = [
        ".envrc"
        ".direnv/"
      ];

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

      userName = "Andrei Lapshin";
      userEmail = config.secrets.contents.email.fastmail;

      includes = [
        { path = /. + dotfileDir + "/git/config"; }
        {
          condition = "gitdir:~/work/qic/";
          contents = {
            core = {
              sshCommand = "ssh -i ~/.ssh/qic_id_ed25519";
            };
            user = {
              name = "Andrei Lapshin";
              email = config.secrets.contents.email.work-qic;
            };
          };
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
            selectedLineBgColor = [
              "default"
              "bold"
            ];
            selectedRangeBgColor = [
              "reverse"
              "bold"
            ];
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

    git-worktree-switcher.enable = true;
  };
}
