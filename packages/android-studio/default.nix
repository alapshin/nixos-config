{ callPackage, makeFontsConf, gnome2, buildFHSUserEnv }:

let
  mkStudio = opts: callPackage (import ./common.nix opts) {
    fontsConf = makeFontsConf {
      fontDirectories = [];
    };
    inherit (gnome2) GConf gnome_vfs;
    inherit buildFHSUserEnv;
  };
  stableVersion = {
    version = "4.2.2.0"; # "Android Studio 4.2.2"
    build = "202.7486908";
    sha256Hash = "18zc9xr2xmphj6m6a1ilwripmvqzplp2583afq1pzzz3cv5h8fvk";
  };
  betaVersion = {
    version = "2020.3.1.20"; # "Android Studio Arctic Fox (2020.3.1) Beta 5"
    sha256Hash = "0swcsjx29ar4b0c8yhbynshqdn2sv94ga58h2nrc99927vp17g85";
  };
  latestVersion = { # canary & dev
    version = "2021.1.1.2"; # "Android Studio Bumblebee (2021.1.1) Canary 2"
    sha256Hash = "10cp4sx6k6hnh5z7r1hf957h7zsq8xncjz83s793ibnki4s1qadr";
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
