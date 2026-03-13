{ inputs, ... }:
{
  flake.modules.nixos.host-midgard = {
    imports = with inputs.self.modules.nixos; [
      server
      ./_hosts/midgard
    ];
  };
}
