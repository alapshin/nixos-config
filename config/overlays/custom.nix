# Overlay containing customisations for packages from nixpkgs
self: super:

let 
  unstableRepo = fetchGit {
    ref = "master";
    url = https://github.com/NixOS/nixpkgs.git;
  };
  unstablePkgs = import unstableRepo { config = self.config; overlays = []; };

  mkStudio = args: super.callPackage (import <nixos/pkgs/applications/editors/android-studio/common.nix> args) {
    fontsConf = super.makeFontsConf {
      fontDirectories = [];
    };
    inherit (super.gnome2) GConf gnome_vfs;
  };
in
{
  home-manager = unstablePkgs.home-manager;

  skype = unstablePkgs.skype;
  jetbrains = unstablePkgs.jetbrains;

  # skrooge = super.skrooge.overrideAttrs (oldAttrs: rec {
  #   pname = "skrooge";
  #   version = "2.21.0";
  #
  #   src = super.fetchurl {
  #     url = "http://download.kde.org/stable/skrooge/${pname}-${version}.tar.xz";
  #     sha256 = "1aqn0367q7mdg728r5085aqzc4mgfz1bgqqlhgdjjp7r192yq7r2";
  #   };
  #   patches = [];
  # });

  neovim = super.neovim.overrideAttrs (oldAttrs: {
    preFixup = ''
        rm -rf $out/share/applications/*.desktop
    '';
  });

  androidStudioPackages = unstablePkgs.androidStudioPackages;
  # androidStudioPackages = super.androidStudioPackages // {
  #   beta = mkStudio {
  #     channel = "beta";
  #     pname = "android-studio-beta";
  #     version = "3.6.0.18"; # "Android Studio 3.6 RC 1"
  #     build = "192.6071332";
  #     sha256Hash = "0xpcihr5xxr9l1kv6aflywshs8fww3s7di0g98mz475whhxwzf3q";
  #   };
  # };

  linuxPackages_latest = super.linuxPackages_latest.extend (linuxSelf: linuxSuper:
  let
    generic = args: linuxSelf.callPackage (import <nixos/pkgs/os-specific/linux/nvidia-x11/generic.nix> args) { };
  in
  {
    nvidiaPackages = linuxSuper.nvidiaPackages // {
      beta = generic {
        version = "440.59";
        sha256_64bit = "162gq6w44l8sgnn4qnl2rdlx8c008p04zv4c3i1ps20p21n1mjv1";
        settingsSha256 = "0vxhmirqzyav5ljf0f04yk0az48ir5v0817dq9z9kyqfdvnby93g";
        persistencedSha256 = "0npjh7nashasydp8q6bbcp21w8fc1dycgjy50ics775hjnvm61qn";
      };
    };
  });
}
