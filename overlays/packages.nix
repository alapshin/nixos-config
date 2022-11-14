# Overlay containing local packages definitions
final: prev: {
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

  etesync-dav = prev.callPackage ../packages/etesync-dav {};

  # OpenSSL 1.0 for Aundroid Auto emilator
  openssl_1_0 = prev.openssl.overrideAttrs(oldAttrs: rec {
    pname = "openssl";
    version = "1.0.2u";
    sha256 = "sha256-7NDG/7ST3QZwfTixS7TYwiiLtwM3NWBladj5D4lmnRY=";
    patches = [];
    withDocs = false;
    src = prev.fetchurl {
      url = "https://www.openssl.org/source/${pname}-${version}.tar.gz";
      inherit sha256;
    };
    outputs = [ "bin" "dev" "out" "man" ];
  });

  android-fhs-env = prev.callPackage ../packages/android-fhs-env {};
  firacode-nerdfonts = prev.nerdfonts.override {fonts = ["FiraCode"];};

  androidStudioPackages =
    prev.recurseIntoAttrs
    (prev.callPackage ../packages/android-studio {
      buildFHSUserEnv = prev.buildFHSUserEnvBubblewrap;
    });

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = prev.xorg.xkeyboardconfig.overrideAttrs(oldAttrs: rec {
    patches = [
      ../packages/xkb/custom-us-hbs.patch
    ];
  });

}
