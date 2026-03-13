{ inputs, self, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = import ../pkgs-config.nix { lib = inputs.nixpkgs.lib; };
        overlays = (builtins.attrValues self.overlays) ++ [ inputs.nur.overlays.default ];
      };
    };
}
