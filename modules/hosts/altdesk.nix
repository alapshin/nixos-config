{ inputs, ... }:
{
  flake.modules.nixos.host-altdesk = {
    imports = with inputs.self.modules.nixos; [
      default
      audio
      bluetooth
      backup
      alapshin
      ./_hosts/altdesk
    ];
  };
}
