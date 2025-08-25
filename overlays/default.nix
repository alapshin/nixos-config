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
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
        mitmproxy = pyprev.mitmproxy.overridePythonAttrs (old: rec {
          version = "12.1.2";
          src = prev.fetchFromGitHub {
            owner = "mitmproxy";
            repo = "mitmproxy";
            tag = "v${version}";
            hash = "sha256-XYZ14JlVYG/OLlEze+C1L/HP3HD5GEW+jG2YYSXW/8Y=";
          };
          pythonRelaxDeps = [
            "h2"
            "passlib"
            "urwid"
          ];
        });
        mitmproxy-rs = pyprev.mitmproxy-rs.overridePythonAttrs (old: rec {
          pname = "mitmproxy-rs";
          version = "0.12.7";
          src = prev.fetchFromGitHub {
            owner = "mitmproxy";
            repo = "mitmproxy_rs";
            tag = "v${version}";
            hash = "sha256-Wd/4XzSMQ3qgacFUlxReQFyonUbTqWKDCk3m+kWhXy0=";
          };
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit pname version src;
            hash = "sha256-Q5EBI5uXJgbI9NMblkTT/GweopnTr/zUG35i+Aoe3QA=";
          };
        });
        mitmproxy-macos = pyprev.mitmproxy-macos.overridePythonAttrs (old: rec {
          version = "0.12.7";
          src = prev.fetchPypi {
            pname = "mitmproxy_macos";
            inherit version;
            format = "wheel";
            dist = "py3";
            python = "py3";
            hash = "sha256-NArp10yhERk7Hhw5fIU+ekbupyldyzpLQdKgebiUpOM=";
          };
        });
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };
}
