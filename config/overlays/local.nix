# Overlay containing local packages definitions

self: super:

{
  android-fhs-run = self.callPackage ../../pkgs/android-fhs-run {};
}
