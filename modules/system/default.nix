{ inputs, ... }:
{
  flake.modules.nixos.default = {
    imports = with inputs.self.modules.nixos; [
      base
      boot
      infra
    ];
  };

  flake.modules.darwin.default = {
    imports = with inputs.self.modules.darwin; [
      base
    ];
  };
}
