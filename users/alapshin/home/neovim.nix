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
      tint-nvim
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
      none-ls-nvim
      lspkind-nvim
      nvim-lspconfig
      inc-rename-nvim
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects

      noice-nvim
      nvim-notify

      trouble-nvim
      lualine-nvim
      gitsigns-nvim
      neo-tree-nvim
      bufferline-nvim
      nvim-web-devicons
      telescope-nvim
      telescope-fzf-native-nvim

      indent-blankline-nvim
    ];
    extraPackages = with pkgs; [
      alejandra
      gitlint
      # hadolint

      nil
      statix

      selene
      lua-language-server

      beancount
      beancount-language-server
    ];
  };
}
