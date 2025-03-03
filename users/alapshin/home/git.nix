{
  pkgs,
  config,
  dotfileDir,
  ...
}:
let
  accounts = builtins.fromJSON (builtins.readFile ./../secrets/build/accounts.json);
in
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
      userEmail = accounts.fastmail;

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
              email = accounts.work-qic;
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
