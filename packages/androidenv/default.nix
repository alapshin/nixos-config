{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  toolsVersion = "26.1.1";
  cmdLineToolsVersion = "16.0";
  platformToolsVersion = "35.0.2";
  buildToolsVersions = [
    "34.0.0"
    "35.0.0"
  ];

  includeNDK = true;
  ndkVersions = [ "27.2.12479018" ];

  includeEmulator = true;
  emulatorVersion = "35.2.10";

  includeSources = true;
  includeSystemImages = true;
  abiVersions = [ "x86_64" "x86" ];
  platformVersions = [ "34" "35" ];
  systemImageTypes = [ "google_apis_playstore" ];
}
