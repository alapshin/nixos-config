# Overlay containing customisations for packages from nixpkgs
self: super:
{
  skrooge = super.skrooge.overrideAttrs (oldAttrs: rec {
    pname = "skrooge";
    version = "2.21.0";

    src = super.fetchgit {
      url = "https://anongit.kde.org/skrooge.git";
      rev = "08f400c7c5db0f262c320ee1ccad6960d755910e";
      sha256 = "1n6akxwk3jbjbp7nayvpk4lzkzjpq4f7lk6463gycbyndy93hyi4";
    };

    patches = [];
  });

  linuxPackages_latest = super.linuxPackages_latest.extend (linuxSelf: linuxSuper:
  let
    generic = args: linuxSelf.callPackage (import <nixos/pkgs/os-specific/linux/nvidia-x11/generic.nix> args) { };
  in
  {
    nvidiaPackages = linuxSuper.nvidiaPackages // {
      beta = generic {
        version = "440.36";
        sha256_64bit = "0nbdldwizb802w4x0rqnyb1p7iqz5nqiahqr534n5ihz21a6422h";
        settingsSha256 = "07hnl3bq76vsl655ipfx9v4zxjq0nc5hp43dk49nny4pi6ly06p1";
        persistencedSha256 = "08zm1i5sax16xfhkivkmady0yy5argmxv846x21q98ry1ic6cp6w";
      };
    };
  });
}
