{
  stdenv,
  buildFHSEnv,
  runtimeShell,
  writeScript,
  extraPkgs ? pkgs: [],
}:
buildFHSEnv {
  name = "android-fhs-env";

  runScript = "zsh";

  profile = ''
    export JAVA_HOME="/usr/lib64/openjdk/"
  '';

  targetPkgs = pkgs:
    with pkgs;
      [
        zsh
        bash
        coreutils
        file
        findutils
        git
        jdk
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
      ]
      ++ extraPkgs pkgs;

  multiPkgs = pkgs:
    with pkgs; [
      zlib
    ];
}
