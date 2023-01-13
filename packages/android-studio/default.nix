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
    version = "2022.1.1.19"; # "Android Studio Electric Eel (2022.1.1)"
    sha256Hash = "luxE6a2C86JB28ezuIZV49TyE314S1RcNXQnCQamjUA=";
  };
  betaVersion = {
    version = "2022.1.1.18"; # "Android Studio Electric Eel (2022.1.1) RC 3"
    sha256Hash = "0Fihl/WW37F6ICeNuAvFkYuY4s2xjsa5gNmTbzklkr0=";
  };
  latestVersion = { # canary & dev
    version = "2022.2.1.11"; # "Android Studio Flamingo (2022.2.1) Canary 11"
    sha256Hash = "i4lKtKvqyglqthgfsF1bzdf+NupsPcpS/bzjqtQZe6I=";
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
