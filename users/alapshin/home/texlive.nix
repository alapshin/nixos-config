{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [ typst ];

  programs.texlive = {
    enable = false;
    packageSet = pkgs.texlive;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        arydshln
        csquotes
        latexmk
        moderncv
        multirow
        academicons
        fontawesome5

        fontspec
        microtype
        polyglossia

        scheme-medium
        collection-luatex
        ;
    };
  };
}
