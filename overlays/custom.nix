final: prev:
{
  mesa = (prev.mesa.override { 
    llvmPackages = prev.llvmPackages_latest; 
  }).overrideAttrs (oldAttrs : rec {
    version = "20.3.1";
    src = prev.fetchurl {
      urls = [
        "https://mesa.freedesktop.org/archive/mesa-${version}.tar.xz"
      ];
      sha256 = "03vqm9kqrcpijg6bxldj0bg360z8d7c767n3b16jdc1apd4inxdg";
    };
  });
  llvmPackages = prev.llvmPackages_latest;
}
