# Overlay containing local packages definitions
self: super:
{
  fhs-run = super.callPackage ../../pkgs/fhs-run { };
}
