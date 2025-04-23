{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: _prev: {
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
    changedetection-io = prev.changedetection-io.overrideAttrs (oldAttrs: rec {
      version = "0.49.4";
      src = prev.fetchFromGitHub {
        owner = "dgtlmoon";
        repo = "changedetection.io";
        tag = version;
        hash = "sha256-EmtJ8XXPb75W4VPj4Si9fdzVLDKVfm+8P6UZZlMpMdI=";
      };
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
