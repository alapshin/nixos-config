{ inputs, ... }: {
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    birdtray-autostart = prev.makeAutostartItem {
      name = "Birdtray";
      package = prev.birdtray;
      srcPrefix = "com.ulduzsoft.";
    };
    keepassxc-autostart = prev.makeAutostartItem {
      name = "KeePassXC";
      package = prev.keepassxc;
      srcPrefix = "org.keepassxc.";
    };

    nerdfonts = prev.nerdfonts.override {
      fonts = [
        "JetBrainsMono"
      ];
    };

    libsForQt5 = prev.libsForQt5 // {
      bismuth = prev.libsForQt5.bismuth.overrideAttrs (finalAttrs: previousAttrs: {
        patches =
          (previousAttrs.patches or [ ])
            ++ [
            # (fetchpatch {
            #   name = "bismuth-3.1-4-border-color.patch";
            #   url = "https://github.com/I-Want-ToBelieve/bismuth/commit/dac110934fe1ae0da9e4aca8c331f27987b033cf.patch";
            #   sha256 = "sha256-3fQs/A4hc/qeiu+792nZBTl4ujg8rQD25kuwNr03YUs=";
            # })
            (prev.fetchpatch {
              name = "bismuth-3.1-4-static-block.patch";
              url = "https://github.com/I-Want-ToBelieve/bismuth/commit/99438b55a82f90d4df3653d00f1f0978eddc2725.patch";
              sha256 = "sha256-jEt0YdS7k0bJRIS0UMY21o71jgrJcwNp3gFA8e8TG6I=";
            })
            (prev.fetchpatch {
              name = "bismuth-3.1-4-window-id.patch";
              url = "https://github.com/jkcdarunday/bismuth/commit/ce377a33232b7eac80e7d99cb795962a057643ae.patch";
              sha256 = "sha256-15txf7pRhIvqsrBdBQOH1JDQGim2Kh5kifxQzVs5Zm0=";
            })
          ];
      });
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
