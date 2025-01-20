{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: _prev: {
    rocmpr = import inputs.nixpkgs-rocm { system = final.system; };
    beancountpr = import inputs.nixpkgs-beancount3 { system = final.system; };
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    ollama = prev.rocmpr.ollama;
    rocmPackages = prev.rocmpr.rocmPackages.gfx1030;

    fava = prev.callPackage prev.beancountpr.fava.override { };

    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        petl = prev.beancountpr.python3Packages.petl;
        beancount = prev.beancountpr.python3Packages.beancount3;
        autobean = pyfinal.callPackage ../packages/autobean { };
        beangulp = pyfinal.callPackage prev.beancountpr.python3Packages.beangulp.override { };

        torch = pyfinal.callPackage prev.rocmpr.python3Packages.torch.override { };
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };

}
