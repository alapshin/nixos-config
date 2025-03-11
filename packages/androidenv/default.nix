{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  toolsVersion = "26.1.1";
  cmdLineToolsVersion = "17.0";
  platformToolsVersion = "35.0.2";
  buildToolsVersions = [
    "30.0.3"
    "34.0.0"
    "35.0.0"
  ];

  includeNDK = true;
  ndkVersions = [ "27.2.12479018" ];

  includeEmulator = true;
  emulatorVersion = "35.3.11";

  includeSources = true;
  includeSystemImages = true;
  abiVersions = [
    "x86"
    "x86_64"
  ];
  platformVersions = [
    "32"
    "34"
    "35"
  ];
  systemImageTypes = [ "google_apis_playstore" ];
}
