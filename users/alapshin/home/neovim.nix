{
  config,
  pkgs,
  ...
}: let
  nvim-beancount = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-beancount";
    version = "2020-05-24";
    src = pkgs.fetchFromGitHub {
      owner = "polarmutex";
      repo = "beancount.nvim";
      rev = "067e6a26a828437ecd72a250a656bf63d5a33d32";
      sha256 = "6xlrXcJq91OvPkjcnbqrZmxad8H3oZTEJ1wf4Rx9hCc=";
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

      plenary-nvim

      comment-nvim
      which-key-nvim

      luasnip
      nvim-cmp
      cmp-nvim-lsp
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
