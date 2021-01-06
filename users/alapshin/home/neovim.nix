{ config, dirs, myutils, pkgs, ... }:
let
  hmcfg = config.home-manager.users."${username}";
  username = myutils.extractUsername (builtins.toString ./.);
  breezy = pkgs.vimUtils.buildVimPlugin {
    name = "breezy";
    src = pkgs.fetchFromGitHub {
      owner = "fneu";
      repo = "breezy";
      rev = "453167dc346f39e51141df4fe7b17272f4833c2b";
      sha256 = "6xlrXcJq91OvPkjcnbqrZmxad8H3oZTEJ1wf4Rx9hCc=";
    };
  };
in
{
  home-manager.users."${username}" = {
    programs.neovim = {
      enable = true;
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
      ];
      extraConfig = ''
        source ${hmcfg.xdg.configHome}/nvim/config.vim
      '';
    };
  };
}
