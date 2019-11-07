# Overlay containing local packages definitions
self: super:
{
  android-fhs-run = super.callPackage ../../pkgs/android-fhs-run { };

  hunspellDicts = super.recurseIntoAttrs (super.callPackages ../../pkgs/hunspell/dictionaries.nix {});
}
