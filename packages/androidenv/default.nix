{ pkgs, ... }:

pkgs.androidenv.composeAndroidPackages {
  repoJson = ./repo.json;

  includeNDK = true;
  includeSources = true;
  includeEmulator = true;
  includeSystemImages = true;
  abiVersions = [
    "x86_64"
  ];
  platformVersions = [
    "30"
    "32"
    "34"
    "35"
  ];
  buildToolsVersions = [
    "30.0.3"
    "34.0.0"
    "36.0.0"
  ];
  systemImageTypes = [ "google_apis_playstore" ];
}
