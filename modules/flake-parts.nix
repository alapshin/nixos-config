# Enable the flake.modules.<class>.<name> option from flake-parts
# This is the foundation of the Dendritic pattern
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    # Import home-manager's flake module
    inputs.home-manager.flakeModules.home-manager
  ];
}
