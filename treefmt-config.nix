{ pkgs, ... }:
{
  programs.shfmt = {
    enable = true;
    # Use .editorconfig config
    indent_size = null;
  };
  programs.nixfmt.enable = true;
  programs.jsonfmt.enable = true;
  programs.yamlfmt.enable = true;
}
