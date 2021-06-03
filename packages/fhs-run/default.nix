{ stdenv, buildFHSUserEnv, runtimeShell, writeScript, extraPkgs ? pkgs: [ ] }:

buildFHSUserEnv {
  name = "fhs-run";

  targetPkgs = pkgs: with pkgs; [
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

  runScript = writeScript "fhs-exec" ''
    #!${runtimeShell}
    run="$1"
    if [ ! -z "$run" ]; then
      shift
      exec -- "$run" "$@"
    else
      echo "Usage: fhs-run command-to-run args..." >&2
    fi
  '';
}
