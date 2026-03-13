{ lib, ... }:
{
  # Generic class module - can be imported into any context
  flake.modules.generic.dotfiles =
    { lib, ... }:
    {
      options.dotfileDir = lib.mkOption {
        type = lib.types.path;
        default = ../../dotfiles;
        readOnly = true;
        description = "Path to raw dotfiles directory";
      };
    };
}
