{ config, pkgs, ... }:

{
  programs.adb.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk14;
  };

  environment.systemPackages = with pkgs; [
    fhs-run

    # Git
    git-lfs
    gitRepo
    gitAndTools.git
    gitAndTools.tig
    gitAndTools.git-hub
    gitAndTools.git-crypt
    gitAndTools.transcrypt
    gitAndTools.git-extras
    gitAndTools.git-subrepo
    gitAndTools.git-filter-repo

    # Rust
    # rustc
    # cargo
    # gcc 
    # gnumake
    # openssl
    # pkgconfig

    # Java / Android
    groovy
    android-udev-rules
    jetbrains.idea-ultimate
    androidStudioPackages.stable

    # Python
    (python3.withPackages(ps: with ps; [ 
      ipython 
      notebook
      matplotlib
      numpy
      pandas
      # pelican
      scikitlearn
      seaborn
    ]))
  ];
}
