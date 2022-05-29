{ stdenv, buildFHSUserEnv, runtimeShell, writeScript, extraPkgs ? pkgs: [ ] }:

buildFHSUserEnv {
  name = "android-fhs-env";

  runScript = "zsh";

  targetPkgs = pkgs: with pkgs; [
    zsh
    bash
    coreutils
    file
    findutils
    git
    jdk11
    which
    unzip
  ] ++ extraPkgs pkgs;

  multiPkgs = pkgs: with pkgs; [
    zlib
  ];
}