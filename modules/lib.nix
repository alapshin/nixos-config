# Extended library combining nixpkgs.lib, home-manager.lib, and custom extensions
{ inputs, ... }:
{
  _module.args.lib = inputs.nixpkgs.lib.extend (
    _: prev:
    inputs.home-manager.lib
    // {
      strings = prev.strings // {
        capitalize =
          str:
          prev.strings.toUpper (prev.strings.substring 0 1 str)
          + prev.strings.substring 1 (prev.strings.stringLength str) str;
      };
    }
  );
}
