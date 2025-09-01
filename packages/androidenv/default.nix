{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  includeNDK = true;
  includeSources = true;
  includeEmulator = true;
  includeSystemImages = true;
  platformToolsVersion = "36.0.0";
  abiVersions = [
    "x86_64"
  ];
  platformVersions = [
    "29"
    "35"
    "36"
  ];
  buildToolsVersions = [
    "34.0.0"
    "36.0.0"
  ];
  systemImageTypes = [ "google_apis" "google_apis_playstore" ];
}
