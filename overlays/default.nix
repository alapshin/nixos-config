{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    anki = prev.pkgs.pinned.anki;
    calibre = prev.pkgs.pinned.calibre;
    nerdfonts = prev.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: { unstable = import inputs.nixpkgs { system = final.system; }; };
  # When applied, the pinned nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.pinned'
  pinned-packages = final: _prev: { pinned = import inputs.nixpkgs-pinned { system = final.system; }; };
}
