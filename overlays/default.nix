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
    sonarr = prev.sonarr.overrideAttrs (oldAttrs: rec {
      version = "4.0.4.1668";
      src = prev.fetchurl {
        hash = "sha256-thODsC5hb7G3gTpbtjxXsyTENRDcq/cw3vajLSoNdj0=";
        url = builtins.replaceStrings
          [
            "main"
            oldAttrs.version
          ]
          [
            "develop"
            version
          ]
          oldAttrs.src.url;
      };
    });
  };

  pr-packages = final: _prev: {
    prs = import inputs.authelia {
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
