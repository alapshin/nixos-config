{ inputs, ... }:
{
  flake.modules.nixos.host-carbon = {
    imports = with inputs.self.modules.nixos; [
      desktop
      alapshin
      ./_hosts/carbon
    ];
  };
}
