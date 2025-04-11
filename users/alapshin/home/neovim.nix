{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
in
{
  home.sessionVariables.EDITOR = "nvim";
  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;
      enableLuaLoader = true;

      extraPackages = with pkgs; [
        gitlint
        dotenv-linter
      ];

      extraPlugins = with pkgs.vimPlugins; {
        sleuth = {
          package = vim-sleuth;
        };
      };

      # Run nvim-lint when leaving insert
      autocmds = [
        {
          event = [
            "InsertLeave"
          ];
          callback = mkLuaInline ''
            function()
              require("lint").try_lint()
            end
          '';
        }
      ];

      options = {
        tabstop = 4;
        autoindent = true;
      };

      autocomplete = {
        enableSharedCmpSources = true;
        blink-cmp = {
          enable = true;
          setupOpts = {
            sources = {
              default = [
                "lsp"
                "path"
                "buffer"
                "omni"
                "snippets"
              ];
            };
          };
          sourcePlugins = {
            ripgrep.enable = true;
          };
        };
      };

      binds.whichKey.enable = true;
      comments.comment-nvim.enable = true;

      debugger.nvim-dap.enable = true;

      diagnostics = {
        enable = true;
        config = {
          virtual_text = true;
          virtual_lines = false;
        };
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            gitcommit = [ "gitlint" ];
          };
        };
      };

      filetree.neo-tree.enable = true;

      formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            beancount = [ "bean-format" ];
          };
          formatters = {
            bean-format = {
              prepend_args = [
                "--currency-column"
                "80"
              ];
            };
          };
        };
      };

      git = {
        gitsigns = {
          enable = true;
        };
      };

      languages = {
        enableLSP = true;
        enableTreesitter = true;
        enableFormat = true;
        enableExtraDiagnostics = true;

        bash.enable = true;
        lua.enable = true;
        markdown = {
          enable = true;
          extensions = {
            render-markdown-nvim.enable = true;
          };
        };
        nix = {
          enable = true;
          lsp.server = "nixd";
          format = {
            type = "nixfmt";
            package = pkgs.nixfmt-rfc-style;
          };
        };
        python = {
          enable = true;
        };
        yaml.enable = true;
      };

      lsp = {
        enable = true;
        inlayHints.enable = true;

        lspkind.enable = true;
        trouble.enable = true;
        lightbulb.enable = true;
      };

      notify.nvim-notify = {
        enable = true;
        setupOpts = {
          render = "default";
          timeout = 2500;
        };
      };

      statusline.lualine = {
        enable = true;
        theme = "catppuccin";
      };

      tabline.nvimBufferline = {
        enable = true;
        setupOpts.options = {
          indicator.style = "icon";
          separator_style = "slant";
        };
      };

      telescope = {
        enable = true;
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "latte";
      };

      treesitter = {
        context.enable = true;
        grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          beancount
        ];
      };

      ui = {
        borders = {
          enable = true;
          globalStyle = "rounded";
        };
        breadcrumbs.enable = true;
        colorizer.enable = true;
        fastaction.enable = true;
        # illuminate.enable = true;
        # modes-nvim.enable = true;
        noice = {
          enable = true;
          setupOpts = {
            presets = {
              inc_rename = true;
              bottom_search = false;
            };
            lsp.override = {
              "cmp.entry.get_documentation" = true;
              "vim.lsp.util.stylize_markdown" = true;
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
            };
          };
        };
        nvim-ufo.enable = true;
        smartcolumn = {
          enable = true;
          setupOpts = {
            custom_colorcolumn = {
              gitcommit = "72";
              beancount = "79";
            };
          };
        };
      };

      visuals = {
        indent-blankline.enable = true;
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;
        rainbow-delimiters.enable = true;
      };

      extraLuaFiles = [
        ./neovim.lua
      ];
    };
  };
}
