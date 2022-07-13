# Overlay containing local packages definitions
final: prev: {
  keepassxc-autostart = prev.makeAutostartItem {
    name = "KeePassXC";
    package = prev.keepassxc;
    srcPrefix = "org.keepassxc.";
  };
  thunderbird-autostart = prev.makeAutostartItem {
    name = "thunderbird";
    package = prev.thunderbird;
  };

  etesync-dav = prev.callPackage ../packages/etesync-dav {};

  android-fhs-env = prev.callPackage ../packages/android-fhs-env {};
  firacode-nerdfonts = prev.nerdfonts.override {fonts = ["FiraCode"];};

  androidStudioPackages =
    prev.recurseIntoAttrs
    (prev.callPackage ../packages/android-studio {
      buildFHSUserEnv = prev.buildFHSUserEnvBubblewrap;
    });
}
