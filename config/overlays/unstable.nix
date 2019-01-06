self: super:

let 
  unstableRepo = fetchGit {
    ref = "master";
    url = https://github.com/NixOS/nixpkgs.git;
  };
  unstablePkgs = import unstableRepo { config = self.config; overlays = []; };
in
{
  home-manager = unstablePkgs.home-manager;

  jetbrains = unstablePkgs.jetbrains;
  androidStudioPackages = unstablePkgs.androidStudioPackages;

  skrooge = unstablePkgs.skrooge.overrideAttrs (oldAttrs: rec {
    name = "skrooge-${version}";
    version = "2.17.0";
    src = self.fetchgit {
      url = "https://anongit.kde.org/skrooge.git";
      rev = "b6cff4bad4c0875ad3b974684cb298b4253388f0";
      sha256 = "11sbrl9868igckbmy6b29rkljga45pqv0ds9y0c28azsdgvmh2jq";
    };
  });
}
