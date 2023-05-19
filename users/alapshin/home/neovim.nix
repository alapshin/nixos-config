{
  config,
  pkgs,
  ...
}: let
   # alias
  shade-nvim = pkgs.vimPlugins.Shade-nvim;

  beancount-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "beancount-nvim";
    version = "2023-01-28";
    src = pkgs.fetchFromGitHub {
      owner = "polarmutex";
      repo = "beancount.nvim";
      rev = "067e6a26a828437ecd72a250a656bf63d5a33d32";
      hash = "sha256-ZiGTiQoMyg2V5QtyuL4owZ4FL9RmJgfv/VtbJDMZTtU=";
    };
  };

  github-theme = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "github-nvim-theme";
    version = "2023-05-17";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "99bf053d4fd6fcdb855ef29824fe18c7429ebdd4";
      hash = "sha256-m8dLckKWodrInO4WLqOxRqdpeN0TW1N6Kb9i/hxpSIE=";
    };
    preInstall = ''
      rm -rf doc
    '';
  };
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      github-theme
      onedark-nvim

      vim-sleuth
      vim-polyglot
      beancount-nvim

      plenary-nvim

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
      nvim-lspconfig
      nvim-treesitter.withAllGrammars

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
      hadolint
      selene
      statix
      rnix-lsp

      lua-language-server
      beancount-language-server
    ];
  };
}
