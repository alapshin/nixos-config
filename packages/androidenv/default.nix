{ pkgs, ... }:

let
  buildToolsVersion = "35.0.0";
in pkgs.androidenv.composeAndroidPackages {
    repoJson = ./packages/androidenv/repo.json;

    toolsVersion = "26.1.1";
    cmdLineToolsVersion = "16.0";
    platformToolsVersion = "35.0.2";
    buildToolsVersions = [ buildToolsVersion ];

    includeNDK = true;
    ndkVersions = [ "27.2.12479018" ];

    includeEmulator = false;
    emulatorVersion = "35.2.10";
}
