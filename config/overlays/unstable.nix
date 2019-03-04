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

  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      tensorflow = unstablePkgs.python37Packages.tensorflow;
      tensorflowWithCuda = unstablePkgs.python37Packages.tensorflowWithCuda;
    };
  };
}
