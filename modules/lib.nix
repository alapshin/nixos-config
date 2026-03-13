# Extended library combining nixpkgs.lib, home-manager.lib, and custom extensions
{ inputs, ... }:
{
  _module.args.lib = inputs.nixpkgs.lib.extend (
    _: prev: inputs.home-manager.lib // (import ../lib { lib = prev; })
  );
}
