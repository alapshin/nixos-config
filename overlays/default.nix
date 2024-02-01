{ inputs, ... }: {
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    nerdfonts = prev.nerdfonts.override {
      fonts = [
        "JetBrainsMono"
      ];
    };
    catppuccin-kde = prev.catppuccin-kde.override {
      accents = [ "sky" ];
      flavour = [ "latte" ];
    };
  };

  pr-packages = final: _prev: {
    prs = import inputs.subtitlecomposer {
      system = final.system;
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
    };
  };
}
