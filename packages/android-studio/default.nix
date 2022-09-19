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
    version = "2021.3.1.16"; # "Android Studio Dolphin (2021.3.1)"
    sha256Hash = "16hxz47fa8gigw2k9qp6npsf6ih46q1zgjin8fa3px46axc5nwhs";
  };
  betaVersion = {
    version = "2021.3.1.14"; # "Android Studio Dolphin (2021.3.1) Beta 5"
    sha256Hash = "k1Qt54u45rwHsQNz9TVqnFB65kBKtfFZ3OknpfutKPI=";
  };
  latestVersion = { # canary & dev
    version = "2022.1.1.10"; # "Android Studio Electric Eel (2022.1.1) Canary 10"
    sha256Hash = "0jp0ag23v0dwnkbk0pyfs0rsdzqr802sz0x586zm6nxz23j9h5p8";
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
