{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  includeNDK = true;
  includeSources = true;
  includeEmulator = true;
  includeSystemImages = true;
  platformToolsVersion = "35.0.2";
  abiVersions = [
    "x86_64"
  ];
  platformVersions = [
    "34"
    "35"
  ];
  buildToolsVersions = [
    "30.0.3"
    "34.0.0"
    "36.0.0"
  ];
  systemImageTypes = [ "google_apis" "google_apis_playstore" ];
}
