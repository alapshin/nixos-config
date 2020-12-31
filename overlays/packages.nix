# Overlay containing local packages definitions
final: prev:
{
  fhs-run = prev.callPackage ../packages/fhs-run { };
  firacode-nerdfonts = prev.nerdfonts.override { fonts = [ "FiraCode" ]; };
}
