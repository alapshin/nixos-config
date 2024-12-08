{ pkgs, ... }:
{
  programs.shfmt = {
    enable = true;
    # Use .editorconfig config
    indent_size = null;
  };
  programs.jsonfmt.enable = true;
  programs.yamlfmt.enable = true;
  programs.nixfmt-rfc-style.enable = true;
}
