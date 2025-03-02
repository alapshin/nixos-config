{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: _prev: {
    rocmpr = import inputs.nixpkgs-rocm { system = final.system; };
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    ollama = prev.rocmpr.ollama.override { };
    rocmPackages = prev.rocmpr.rocmPackages.gfx1030;
    rocmPackages_6 = prev.rocmpr.rocmPackages_6.gfx1030;

    open-webui = prev.rocmpr.open-webui.override { };
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };

        torch = pyfinal.callPackage prev.rocmpr.python3Packages.torch.override { };
        torchaudio = pyfinal.callPackage prev.rocmpr.python3Packages.torchaudio.override { };
      })
    ];

    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;
  };

}
