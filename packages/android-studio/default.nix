{ callPackage, makeFontsConf, gnome2, buildFHSUserEnv, tiling_wm ? false }:

let
  mkStudio = opts: callPackage (import ./common.nix opts) {
    fontsConf = makeFontsConf {
      fontDirectories = [];
    };
    inherit (gnome2) GConf gnome_vfs;
    inherit buildFHSUserEnv;
    inherit tiling_wm;
  };
  stableVersion = {
    version = "2022.1.1.21"; # "Android Studio Electric Eel (2022.1.1) Patch 2"
    sha256Hash = "sha256-C8omxF2vXK15sTHDQBO5hdFGolJpkOoqptiHktUZBaE=";
  };
  betaVersion = {
    version = "2022.2.1.17"; # "Android Studio Flamingo (2022.2.1) RC 1"
    sha256Hash = "sha256-qUX4QOzeDkCMOOYi2Zhdlc0CkiC8BL8H8IjIomtBvvM=";
  };
  latestVersion = { # canary & dev
    version = "2022.3.1.11"; # "Android Studio Girrafe (2022.3.1) Canary 11"
    sha256Hash = "sha256-hQ0t7EbM22Ah8zL6jllzj1HY/9nktk4xliTyGOqqgS4=";
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
