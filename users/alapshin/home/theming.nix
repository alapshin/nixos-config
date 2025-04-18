{
  lib,
  pkgs,
  config,
  ...
}:
{
  catppuccin = {
    accent = "mauve";
    flavor = "latte";

    bat.enable = true;
    delta.enable = true;
    bottom.enable = true;
    gh-dash.enable = true;
    lazygit.enable = true;
    obs.enable = true;
    starship.enable = true;
    thunderbird.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
