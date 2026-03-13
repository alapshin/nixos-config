{ inputs, ... }:
{
  flake.modules.nixos.desktop = {
    imports = with inputs.self.modules.nixos; [
      default
      audio
      backup
      bluetooth
    ];
  };
}
