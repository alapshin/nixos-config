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

  # linuxPackages_latest = super.linuxPackages_latest.extend (linuxSelf: linuxSuper:
  # let
  #   generic = args: linuxSelf.callPackage (import <nixos/pkgs/os-specific/linux/nvidia-x11/generic.nix> args) { };
  # in
  # {
  #   nvidiaPackages = linuxSuper.nvidiaPackages // {
  #     beta = generic {
  #       version = "440.82";
  #       sha256_64bit = "13km9800skyraa0s312fc4hwyw5pzb0jfkrv1yg6anppyan1bm7d";
  #       settingsSha256 = "15psxvd65wi6hmxmd2vvsp2v0m07axw613hb355nh15r1dpkr3ma";
  #       persistencedSha256 = "13izz9p2kg9g38gf57g3s2sw7wshp1i9m5pzljh9v82c4c22x1fw";
  #     };
  #   };
  # });
}
