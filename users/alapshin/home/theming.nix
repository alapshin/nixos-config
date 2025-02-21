{
  lib,
  pkgs,
  config,
  ...
}: {
  catppuccin = {
    accent = "mauve";
    flavor = "latte";

    bat.enable = true;
    delta.enable = true;
    bottom.enable = true;
    lazygit.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
