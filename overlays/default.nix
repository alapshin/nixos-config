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
    fish = prev.fish.overrideAttrs (
      finalAttrs: oldAttrs: rec {
        version = "4.3.2";
        src = prev.fetchFromGitHub {
          owner = "fish-shell";
          repo = "fish-shell";
          tag = version;
          hash = "sha256-/B4U3giKGmU5B/L5HQLS1lU8f7hsfI4aCeOjWcQ1dpA=";
        };
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) src patches;
          hash = "sha256-/udRRs/ieLfazVTwM47ElExN40QdAG/OqQXmYurgC1I=";
        };
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
