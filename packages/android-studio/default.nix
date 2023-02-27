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
    version = "2022.1.1.20"; # "Android Studio Electric Eel (2022.1.1) Patch 1"
    sha256Hash = "sha256-UX7aOpTM23S7NBPNAz/fKEyK/dqWpok0NnpX9wck6p4=";
  };
  betaVersion = {
    version = "2022.2.1.14"; # "Android Studio Flamingo (2022.2.1) Beta 3"
    sha256Hash = "sha256-lzJv4t5M5DdjJ7GT0JTFlylVl9554svbmjaDHxUuOUo=";
  };
  latestVersion = { # canary & dev
    version = "2022.3.1.6"; # "Android Studio Girrafe (2022.3.1) Canary 6"
    sha256Hash = "sha256-gjZrenL4+G6xkoMSNMqiDqzjaGAQI4MkCohyyf6ObbE=";
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
