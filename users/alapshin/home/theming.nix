{
  lib,
  pkgs,
  config,
  ...
}: {
  catppuccin = {
    flavor = "latte";
    accent = "lavender";

    bat.enable = true;
    # delta.enble = true;
    bottom.enable = true;
    lazygit.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;
  };
}
