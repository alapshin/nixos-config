{
  config,
  pkgs,
  ...
}: let
  beancount-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "beancount-nvim";
    version = "2023-0l-28";
    src = pkgs.fetchFromGitHub {
      owner = "polarmutex";
      repo = "beancount.nvim";
      rev = "067e6a26a828437ecd72a250a656bf63d5a33d32";
      hash = "sha256-ZiGTiQoMyg2V5QtyuL4owZ4FL9RmJgfv/VtbJDMZTtU=";
    };
  };
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      onedark-nvim

      vim-polyglot
      beancount-nvim

      plenary-nvim

      comment-nvim
      which-key-nvim

      luasnip
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      nvim-lspconfig
      nvim-treesitter.withAllGrammars

      noice-nvim
      nvim-notify
      trouble-nvim
      lualine-nvim
      gitsigns-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      indent-blankline-nvim
    ];
    extraPackages = with pkgs; [
      beancount-language-server
    ];
  };
}
