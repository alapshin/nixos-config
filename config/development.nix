{ config, pkgs, ... }:

{
  programs.adb.enable = true;
  programs.ccache.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.adoptopenjdk-openj9-bin-11;
  };

  environment.systemPackages = with pkgs; [
    fhs-run

    git-lfs
    gitRepo
    gitAndTools.git
    gitAndTools.tig
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.transcrypt
    gitAndTools.git-extras

    rustc
    cargo
    gcc 
    gnumake
    openssl
    pkgconfig

    nodePackages.npm
    nodePackages.node2nix

    groovy
    android-udev-rules
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    androidStudioPackages.stable
    androidStudioPackages.beta
    androidStudioPackages.canary


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
