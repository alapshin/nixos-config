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
}
