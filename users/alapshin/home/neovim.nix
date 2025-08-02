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
        nvim-cmp = {
          enable = false;
          sources = { };
        };
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

      binds = {
        whichKey.enable = true;
        hardtime-nvim.enable = true;
      };

      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers.wl-copy.enable = pkgs.stdenv.hostPlatform.isLinux;
      };

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
        git-conflict.enable = true;
      };

      languages = {
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
            package = pkgs.nixfmt;
          };
        };
        python.enable = true;
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

      spellcheck = {
        enable = true;
        languages = [
          "en"
          "ru"
        ];
      };

      statusline.lualine = {
        enable = true;
        theme = "catppuccin";
        activeSection = {
          a = [
            ''
              {
                "mode",
              }
            ''
          ];
          b = [
            ''
              {
                "filetype",
                colored = true,
                icon_only = true,
                icon = { align = 'left' }
              }
            ''
            ''
              {
                "filename",
                symbols = {modified = ' ', readonly = ' '},
              }
            ''
          ];
          c = [
            ''
              {
                "diff",
                colored = false,
                diff_color = {
                  -- Same color values as the general color option can be used here.
                  added    = 'DiffAdd',    -- Changes the diff's added color
                  modified = 'DiffChange', -- Changes the diff's modified color
                  removed  = 'DiffDelete', -- Changes the diff's removed color you
                },
                symbols = {added = '+', modified = '~', removed = '-'}, -- Changes the diff symbols
              }
            ''
          ];
          x = [
            ''
              {
                -- Lsp server name
                function()
                  local buf_ft = vim.bo.filetype
                  local excluded_buf_ft = { toggleterm = true, NvimTree = true, ["neo-tree"] = true, TelescopePrompt = true }

                  if excluded_buf_ft[buf_ft] then
                    return ""
                    end

                  local bufnr = vim.api.nvim_get_current_buf()
                  local clients = vim.lsp.get_clients({ bufnr = bufnr })

                  if vim.tbl_isempty(clients) then
                    return "No Active LSP"
                  end

                  local active_clients = {}
                  for _, client in ipairs(clients) do
                    table.insert(active_clients, client.name)
                  end

                  return table.concat(active_clients, ", ")
                end,
                icon = ' ',
              }
            ''
            ''
              {
                "diagnostics",
                sources = {'nvim_lsp', 'nvim_diagnostic', 'nvim_diagnostic', 'vim_lsp', 'coc'},
                symbols = {error = '󰅙  ', warn = '  ', info = '  ', hint = '󰌵 '},
                colored = true,
                update_in_insert = false,
                always_visible = false,
                diagnostics_color = {
                  color_error = { fg = 'red' },
                  color_warn = { fg = 'yellow' },
                  color_info = { fg = 'cyan' },
                },
              }
            ''
          ];
          y = [
            ''
              {
                'searchcount',
                timeout = 120,
                maxcount = 999,
              }
            ''
            ''
              {
                "branch",
                icon = ' •',
              }
            ''
          ];
          z = [
            ''
              {
                "progress",
              }
            ''
            ''
              {"location"}
            ''
            ''
              {
                "fileformat",
                symbols = {
                  dos = '',  -- e70f
                  mac = '',  -- e711
                  unix = '', -- e712
                }
              }
            ''
          ];
        };
      };

      tabline.nvimBufferline = {
        enable = true;
        setupOpts = {
          options = {
            indicator.style = "icon";
          };
          highlights = lib.mkLuaInline ''
            require("catppuccin.groups.integrations.bufferline").get {
              styles = { "bold" },
              custom = {
                latte = {
                  fill = { bg = latte.mantle },
                },
              },
            }
          '';
        };
      };

      telescope = {
        enable = true;
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "latte";
        extraConfig = ''
          require("catppuccin").setup({
            show_end_of_buffer = true,
            integrations = {
              blink_cmp = true,
            },
          })
          local latte = require("catppuccin.palettes").get_palette "latte"
        '';
      };

      treesitter = {
        grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };

      ui = {
        borders = {
          enable = true;
          globalStyle = "rounded";
        };
        breadcrumbs.enable = true;
        colorizer = {
          enable = true;
          setupOpts = {
            filetypes = {
              "*" = {
                names = false;
                RGB = true;
                RRGGBB = true;
                RRGGBBAA = true;
                mode = "background";
                always_update = true;
              };
            };
          };
        };
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

      utility = {
        sleuth.enable = true;
      };

      visuals = {
        cinnamon-nvim.enable = true;
        indent-blankline.enable = true;
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;
        tiny-devicons-auto-colors = {
          enable = true;
          setupOpts = {
            colors = mkLuaInline ''latte'';
          };
        };

        rainbow-delimiters.enable = true;
      };

      extraLuaFiles = [
        ./neovim.lua
      ];

      lazy.plugins = {
        "vimade" = {
          package = pkgs.vimPlugins.vimade;
          setupModule = "vimade";
          setupOpts = {
          };
        };
      };
    };
  };
}
