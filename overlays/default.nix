{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: prev: {
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    beanprice = prev.beanprice.overrideAttrs(oldAttrs: rec {
      version = "2.1.0";

      src = oldAttrs.src // {
        tag = "v${version}";
        hash = "sha256-Lhr8CRysZbI6dpPwRSN6DgvnKrxsIzH5YyZXRLU1l3Q=";
      };
    });

    open-webui = prev.open-webui.overridePythonAttrs(oldAttrs: rec {
      dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
    });
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };
}
