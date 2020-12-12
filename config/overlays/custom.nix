# Overlay containing customizations for packages from nixpkgs
self: super:

let 
  unstableRepo = fetchGit {
    ref = "master";
    url = https://github.com/NixOS/nixpkgs.git;
  };
  unstablePackages = import unstableRepo { config = self.config; overlays = []; };
in
{
  jetbrains = unstablePackages.jetbrains;
  home-manager = unstablePackages.home-manager;

  androidStudioPackages = unstablePackages.androidStudioPackages;
  # androidStudioPackages = let
  #   packages = super.androidStudioPackages // {
  #     beta = mkStudio {
  #       channel = "beta";
  #       pname = "android-studio-beta";
  #       version = "4.0.0.16"; # "Android Studio 4.0"
  #       build = "193.6514223";
  #       sha256Hash = "1sqj64vddwfrr9821habfz7dms9csvbp7b8gf1d027188b2lvh3h";
  #     };
  #   };
  #   mkStudio = args: super.callPackage (import <nixos/pkgs/applications/editors/android-studio/common.nix> args) {
  #     fontsConf = super.makeFontsConf {
  #       fontDirectories = [];
  #     };
  #     inherit (super.gnome2) GConf gnome_vfs;
  #   }; 
  # in packages;
}
