{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  toolsVersion = "26.1.1";
  cmdLineToolsVersion = "19.0";
  platformToolsVersion = "35.0.2";
  buildToolsVersions = [
    "34.0.0"
    "35.0.1"
  ];

  includeNDK = true;
  ndkVersions = [ "28.0.13004108" ];

  includeEmulator = true;
  emulatorVersion = "35.4.9";

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
