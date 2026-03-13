{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = inputs.treefmt-nix.lib.mkWrapper pkgs (import ../treefmt-config.nix);
    };
}
