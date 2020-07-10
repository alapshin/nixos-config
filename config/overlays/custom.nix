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
  home-manager = unstablePackages.home-manager;
  jetbrains = unstablePackages.jetbrains;
  androidStudioPackages = unstablePackages.androidStudioPackages;

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
