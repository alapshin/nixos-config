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

      autocomplete = {
        blink-cmp = {
          enable = true;
        };
      };

      binds.whichKey.enable = true;
      comments.comment-nvim.enable = true;

      debugger.nvim-dap.enable = true;

      diagnostics = {
        enable = true;
        nvim-lint = {
          enable = true;
        };
      };
      filetree.neo-tree.enable = true;
      formatter.conform-nvim.enable = true;

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

        null-ls = {
          enable = true;
          setupOpts.debug = true;
          setupOpts.sources = {
            gitcommit = mkLuaInline ''
              require("null-ls").builtins.diagnostics.gitlint
            '';
          };
        };
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
        indent.enable = false;
      };

      ui = {
        borders = {
          enable = true;
          globalStyle = "rounded";
        };
        breadcrumbs.enable = true;
        colorizer.enable = true;
        fastaction.enable = true;
        illuminate.enable = true;
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
        smartcolumn.enable = true;
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
