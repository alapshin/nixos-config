{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    prisma = inputs.nixpkgs-lw.legacyPackages."${prev.system}".prisma;
    linkwarden = inputs.nixpkgs-lw.legacyPackages."${prev.system}".linkwarden;

    ollama = inputs.nixpkgs-rocm.legacyPackages."${prev.system}".ollama;
    rocmPackages = inputs.nixpkgs-rocm.legacyPackages."${prev.system}".rocmPackages.gfx1030;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: { unstable = import inputs.nixpkgs { system = final.system; }; };
}
