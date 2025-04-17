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
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyprev.callPackage ../packages/autobean { };
        flask-limiter = pyprev.flask-limiter.overrideAttrs {
          version = "3.12-unstable-2025-04-16";
          src = prev.fetchFromGitHub {
            owner = "alisaifee";
            repo = "flask-limiter";
            rev = "d4a97dbb53a6e0cc751efc8c30c4d8fc493a7eb6";
            hash = "sha256-XiY+ygzNfaWNyA9vDT6J8g3xwxdMmHUJsYV/1diB8Kw=";
          };
        };
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };
}
