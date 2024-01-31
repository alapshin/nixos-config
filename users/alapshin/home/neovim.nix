{ config
, pkgs
, ...
}:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim

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
      nvim-notify
      tint-nvim
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
