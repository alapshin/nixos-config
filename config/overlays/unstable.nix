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
    version = "2.18.0";
    src = self.fetchgit {
      url = "https://anongit.kde.org/skrooge.git";
      rev = "94102bbfff76ee92bd02a45edabcb430f8d8a525";
      sha256 = "0a1b44jbhgzrhmxcxzk6d4j2hcsqv5kbqbkyrnqgmzm1b6zws43z";
    };
  });
}
