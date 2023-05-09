{
  config,
  pkgs,
  ...
}: let
  breezy = pkgs.vimUtils.buildVimPlugin {
    pname = "breezy";
    version = "2020-05-24";
    src = pkgs.fetchFromGitHub {
      owner = "fneu";
      repo = "breezy";
      rev = "453167dc346f39e51141df4fe7b17272f4833c2b";
      sha256 = "6xlrXcJq91OvPkjcnbqrZmxad8H3oZTEJ1wf4Rx9hCc=";
    };
  };
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      breezy
      fzf-vim
      vimtex
      vim-sneak
      vim-eunuch
      vim-hardtime
      vim-polyglot
      vim-commentary
      vim-fugitive
      vim-surround
      vim-unimpaired
      lightline-vim
      vim-beancount
    ];
    extraConfig = ''
      source $XDG_CONFIG_HOME/nvim/config.vim
    '';
  };
}
