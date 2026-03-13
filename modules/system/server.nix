{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [
      default
      backup
      openssh
    ];
  };
}
