{ config
, pkgs
, ...
}:
let
  # alias
  shade-nvim = pkgs.vimPlugins.Shade-nvim;

  github-theme = pkgs.vimUtils.buildVimPlugin {
    pname = "github-nvim-theme";
    version = "1.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "v1.0.1";
      hash = "sha256-30+5q6qE1GCetNKdUC15LcJeat5e0wj9XtNwGdpRsgk=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      github-theme

      vim-sleuth
      vim-polyglot

      plenary-nvim

      leap-nvim
      comment-nvim
      which-key-nvim

      luasnip
      nvim-cmp
      cmp-buffer
      cmp-cmdline
      cmp-path
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      null-ls-nvim
      lspkind-nvim
      nvim-lspconfig
      inc-rename-nvim
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects

      noice-nvim
      shade-nvim
      nvim-notify
      trouble-nvim
      lualine-nvim
      gitsigns-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      bufferline-nvim
      nvim-web-devicons
      indent-blankline-nvim
    ];
    extraPackages = with pkgs; [
      alejandra
      gitlint
      # hadolint

      statix
      rnix-lsp

      selene
      lua-language-server

      beancount
      beancount-language-server
    ];
  };
}
