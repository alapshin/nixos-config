{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: prev: {
    pr-open-webui = import inputs.nixpkgs-openwebui {
      config = prev.config;
      system = prev.system;
    };
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    beanprice = prev.beanprice.overrideAttrs {
      version = "2.0.0-unstalbe-2025-02-25";
      src = prev.fetchFromGitHub {
        owner = "beancount";
        repo = "beanprice";
        rev = "7a6efa7e0b0c9567df27c98e3fd4e8fc3e1c7117";
        hash = "sha256-FKKmh+xpKuV/mUtRVBHDfKVhPpQnBgUPc9UcIfkHxf8=";
      };
      disabledTestPaths = [
        "beanprice/price_test.py"
        "beanprice/sources/yahoo_test.py"
      ];
    };
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
      })
    ];

    open-webui = prev.pr-open-webui.open-webui;

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };
}
