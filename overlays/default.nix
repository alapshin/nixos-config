{inputs, ...}: {
  # This one brings our custom packages from the 'packages' directory
  additions = final: _prev: import ../packages {pkgs = final;};

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
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
