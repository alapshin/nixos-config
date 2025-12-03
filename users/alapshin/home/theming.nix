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

    atuin.enable = true;
    bat.enable = true;
    bottom.enable = true;
    delta.enable = true;
    fish.enable = true;
    gh-dash.enable = true;
    ghostty.enable = true;
    lazygit.enable = true;
    obs.enable = true;
    starship.enable = true;
    thunderbird.enable = true;
    wezterm.enable = true;
    yazi.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
