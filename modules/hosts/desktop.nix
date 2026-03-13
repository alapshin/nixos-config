{ inputs, ... }:
{
  flake.modules.nixos.host-desktop = {
    imports = with inputs.self.modules.nixos; [
      desktop

      alapshin
      ./_hosts/desktop
    ];
  };
}
