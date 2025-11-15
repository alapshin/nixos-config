{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  pinned =
    final: prev:
    let
      pinnedPkgs = import inputs.nixpkgs-pinned {
        system = prev.system;
        config = prev.config; # Inherit config from main nixpkgs
      };
    in
    {
      open-webui = pinnedPkgs.open-webui.overridePythonAttrs (oldAttrs: {
        dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
      });
    };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    fish = prev.fish.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        fava = pyprev.toPythonModule (
          prev.fava.override {
            python3Packages = pyprev;
          }
        );
        autobean = pyfinal.callPackage ../packages/autobean { };
      })
    ];
  };
}
