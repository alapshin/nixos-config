{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: _prev: {
    beancountpr = import inputs.nixpkgs-beancount3 { system = final.system; };
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    fava = prev.callPackage prev.beancountpr.fava.override { };

    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        petl = prev.beancountpr.python3Packages.petl;
        beancount = prev.beancountpr.python3Packages.beancount3;
        autobean = pyfinal.callPackage ../packages/autobean { };
        beangulp = pyfinal.callPackage prev.beancountpr.python3Packages.beangulp.override { };
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    lldap = inputs.nixpkgs-lldap.legacyPackages."${prev.system}".lldap;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;

    ollama = inputs.nixpkgs-rocm.legacyPackages."${prev.system}".ollama;
    rocmPackages = inputs.nixpkgs-rocm.legacyPackages."${prev.system}".rocmPackages.gfx1030;
  };

}
