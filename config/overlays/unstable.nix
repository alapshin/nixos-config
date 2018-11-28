self: super:

let 
  unstableRepo = fetchGit {
    ref = "master";
    url = https://github.com/NixOS/nixpkgs.git;
  };
  unstablePkgs = import unstableRepo { config = super.config; overlays = []; };
in
{
  skrooge = unstablePkgs.skrooge;
  home-manager = unstablePkgs.home-manager;

  jetbrains.jdk = unstablePkgs.jetbrains.jdk;
  jetbrains.clion = unstablePkgs.jetbrains.clion;
  jetbrains.idea-ultimate = unstablePkgs.jetbrains.idea-ultimate;
  jetbrains.pycharm-professional = unstablePkgs.jetbrains.pycharm-professional;
  androidStudioPackages.stable = unstablePkgs.androidStudioPackages.beta;
  androidStudioPackages.beta = unstablePkgs.androidStudioPackages.beta;
  androidStudioPackages.dev = unstablePkgs.androidStudioPackages.beta;
  androidStudioPackages.canary = unstablePkgs.androidStudioPackages.beta;
}
