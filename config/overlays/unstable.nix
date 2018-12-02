self: super:

let 
  unstableRepo = fetchGit {
    ref = "master";
    url = https://github.com/NixOS/nixpkgs.git;
  };
  unstablePkgs = import unstableRepo { config = self.config; overlays = []; };
in
{
  skrooge = unstablePkgs.skrooge;
  home-manager = unstablePkgs.home-manager;

  jetbrains = unstablePkgs.jetbrains;
  androidStudioPackages = unstablePkgs.androidStudioPackages;

  python36Packages = super.python36Packages // {
    tensorflowWithCuda = unstablePkgs.python36Packages.tensorflowWithCuda;
  };
}
