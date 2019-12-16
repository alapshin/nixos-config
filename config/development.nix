{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.ccache.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.adoptopenjdk-openj9-bin-11;
  };

  environment.systemPackages = with pkgs; [
    git-lfs
    gitRepo
    gitAndTools.git
    gitAndTools.tig
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.git-extras

    rustc
    cargo
    gcc 
    gnumake
    openssl
    pkgconfig

    nodePackages.npm
    nodePackages.node2nix

    android-udev-rules
    android-fhs-run
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    androidStudioPackages.beta
    androidStudioPackages.stable


    (python3.withPackages(ps: with ps; [ 
      ipython 
      notebook
      matplotlib
      numpy
      pandas
      pelican
      scikitlearn
      seaborn
    ]))
  ];
}
