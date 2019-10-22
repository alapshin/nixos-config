# Overlay containing local packages definitions
self: super:
{
  android-fhs-run = super.callPackage ../../pkgs/android-fhs-run { };
}
