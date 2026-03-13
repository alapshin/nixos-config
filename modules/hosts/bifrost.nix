{ inputs, ... }:
{
  flake.modules.nixos.host-bifrost = {
    imports = with inputs.self.modules.nixos; [
      server
      ./_hosts/bifrost
    ];
  };
}
