{ callPackage, makeFontsConf, gnome2, buildFHSEnv, tiling_wm ? false }:

let
  mkStudio = opts: callPackage (import ./common.nix opts) {
    fontsConf = makeFontsConf {
      fontDirectories = [];
    };
    inherit (gnome2) GConf gnome_vfs;
    inherit buildFHSEnv;
    inherit tiling_wm;
  };
  stableVersion = {
    version = "2022.2.1.20"; # "Android Studio Flamingo (2022.2.1) Patch 2"
    sha256Hash = "sha256-X+ZuH4cHKfQtfvOF0kLk+QjQ5AR3pTEparczHEUk+uY=";
  };
  betaVersion = {
    version = "2022.3.1.15"; # "Android Studio Giraffe (2022.3.1) Beta 4"
    sha256Hash = "sha256-wjG5XcChlcO+mhsr6S/im4Lqucp1+cvfaE1RvTqt/sM=";
  };
  latestVersion = {
    version = "2023.1.1.7"; # "Android Studio Hedgehog (2023.1.1) Canary 7"
    sha256Hash = "sha256-aRsVr8csIv2O3wK/4nJsZ6PsfOd0GOqGQ5Pd66ybMQA=";
  };
in {
  # Attributes are named by their corresponding release channels

  stable = mkStudio (stableVersion // {
    channel = "stable";
    pname = "android-studio";
  });

  beta = mkStudio (betaVersion // {
    channel = "beta";
    pname = "android-studio-beta";
  });

  dev = mkStudio (latestVersion // {
    channel = "dev";
    pname = "android-studio-dev";
  });

  canary = mkStudio (latestVersion // {
    channel = "canary";
    pname = "android-studio-canary";
  });
}
