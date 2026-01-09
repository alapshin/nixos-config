{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # pinned =
  #   final: prev:
  #   let
  #     pinnedPkgs = import inputs.nixpkgs-pinned {
  #       config = prev.config; # Inherit config from main nixpkgs
  #       system = prev.stdenv.hostPlatform.system;
  #     };
  #   in
  #   {
  #     open-webui = pinnedPkgs.open-webui.overridePythonAttrs (oldAttrs: {
  #       dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
  #     });
  #   };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    mos = prev.mos.overrideAttrs (
      finalAttrs: oldAttrs: {
        version = "4.0.0-beta-1201";
        buildId = "123826";
        src = prev.fetchurl {
          url = "https://github.com/Caldis/Mos/releases/download/${finalAttrs.version}/Mos.Versions.${finalAttrs.version}-${finalAttrs.buildId}.zip";
          hash = "sha256-wjjjrWHSCyFCqFeJEWXe15KOCwTiNZqG+5ydauHKUAo=";
        };
        nativeBuildInputs = [
          prev.unzip
        ];
      }
    );
    ghostty-bin = prev.ghostty-bin.overrideAttrs (oldAttrs: {
      src = prev.fetchurl {
        url = "https://github.com/ghostty-org/ghostty/releases/download/tip/Ghostty.dmg";
        hash = "sha256-0OYJlc7a5095u9UhXtIAqUja62rskyRClbB1eGI7PPc=";
      };
    });
    open-webui = prev.open-webui.overridePythonAttrs (oldAttrs: {
      dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
    });
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
     })
    ];
  };
}
