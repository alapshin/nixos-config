{
  lib,
  pkgs,
  config,
  ...
}:
{
  catppuccin = {
    accent = "pink";
    flavor = "latte";

    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    delta.enable = true;
    gh-dash.enable = true;
    lazygit.enable = true;
    obs.enable = true;
    starship.enable = true;
    thunderbird.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
