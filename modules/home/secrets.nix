{
  lib,
  config,
  ...
}:
let
  cfg = config.secrets;

  inherit (lib)
    types
    mkOption
    ;
in
{
  options = {
    secrets = {
      path = mkOption {
        type = types.path;
      };
      contents = mkOption {
        readOnly = true;
        type = types.submodule {
          freeformType = types.attrsOf types.anything;
        };
        default = builtins.fromJSON (builtins.readFile cfg.path);
      };
    };
  };
}
