# Overlay containing local packages definitions

self: super:

{
  birdtray = self.libsForQt5.callPackage ../../pkgs/birdtray {};
  android-fhs-run = self.callPackage ../../pkgs/android-fhs-run {};
}
