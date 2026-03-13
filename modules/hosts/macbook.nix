{ inputs, ... }:
{
  flake.modules.darwin.host-macbook = {
    imports = with inputs.self.modules.darwin; [
      base
      ./_hosts/macbook
    ];
  };
}
