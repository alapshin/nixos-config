# Overlay containing customisations for packages from nixpkgs
self: super:
{
  skrooge = super.skrooge.overrideAttrs (oldAttrs: rec {
    pname = "skrooge";
    version = "2.21.0";

    src = super.fetchurl {
      url = "http://download.kde.org/stable/skrooge/${pname}-${version}.tar.xz";
      sha256 = "1aqn0367q7mdg728r5085aqzc4mgfz1bgqqlhgdjjp7r192yq7r2";
    };
    patches = [];
  });

  neovim = super.neovim.overrideAttrs (oldAttrs: {
    preFixup = ''
      rm -rf $out/share/applications/*.desktop
    '';
  });

  # linuxPackages_latest = super.linuxPackages_latest.extend (linuxSelf: linuxSuper:
  # let
  #   generic = args: linuxSelf.callPackage (import <nixos/pkgs/os-specific/linux/nvidia-x11/generic.nix> args) { };
  # in
  # {
  #   nvidiaPackages = linuxSuper.nvidiaPackages // {
  #     beta = generic {
  #       version = "440.36";
  #       sha256_64bit = "0nbdldwizb802w4x0rqnyb1p7iqz5nqiahqr534n5ihz21a6422h";
  #       settingsSha256 = "07hnl3bq76vsl655ipfx9v4zxjq0nc5hp43dk49nny4pi6ly06p1";
  #       persistencedSha256 = "08zm1i5sax16xfhkivkmady0yy5argmxv846x21q98ry1ic6cp6w";
  #     };
  #   };
  # });
}
