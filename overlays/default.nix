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
  #   };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    mos = prev.mos.overrideAttrs (
      finalAttrs: oldAttrs: {
        version = "4.0.0";
        buildId = "20260220.1";
        src = prev.fetchurl {
          url = "https://github.com/Caldis/Mos/releases/download/${finalAttrs.version}/Mos.Versions.${finalAttrs.version}-${finalAttrs.buildId}.zip";
          hash = "sha256-xxe/joEVoNr2B+e956f4sHgWoXW5FsOo9hNK/IwYqcQ=";
        };
        nativeBuildInputs = [
          prev.unzip
        ];
      }
    );

    open-webui = prev.open-webui.overridePythonAttrs (oldAttrs: {
      dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
    });

    # Fix karakeep build - skip failing cache patch
    karakeep = prev.karakeep.overrideAttrs (oldAttrs: {
      # Remove the preInstall hook that applies the failing patch
      preInstall = null;
    });

    changedetection-io = prev.changedetection-io.overridePythonAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
        final.python3Packages.flask-babel
        final.python3Packages.diff-match-patch
      ];
    });

    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
      })
    ];
  };
}
