{ stdenv, buildFHSUserEnv, runtimeShell, writeScript, extraPkgs ? pkgs: [ ] }:

buildFHSUserEnv {
  name = "android-fhs-env";

  runScript = "env -u JAVA_HOME zsh";

  targetPkgs = pkgs: with pkgs; [
    zsh
    bash
    coreutils
    file
    findutils
    git
    jdk11
    openssl_1_0
    portaudio
    SDL2
    SDL2_gfx
    SDL2_net
    SDL2_ttf
    SDL2_image
    SDL2_mixer
    SDL2_sound
    which
    unzip
  ] ++ extraPkgs pkgs;

  multiPkgs = pkgs: with pkgs; [
    zlib
  ];
}
