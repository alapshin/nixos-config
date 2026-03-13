# Build-time and runtime secrets module
{ ... }:
{
  flake.modules.homeManager.secrets =
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
            description = "Path to the build-time secrets JSON file";
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
    };
}
