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

  inter = prev.inter.overrideAttrs (oldAttrs: rec {
    version = "4.0-beta8";

    src = prev.fetchzip {
      url = "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
      stripRoot = false;
      hash = "sha256-6HZi51/04VRy2s7VYaKM9y3+NODJN7W4saisEesIwNw=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/opentype
      ls -la
      cp Variable/*.ttf $out/share/fonts/opentype

      runHook postInstall
    '';
  });

  nerdfonts = prev.nerdfonts.override { fonts = [
    "JetBrainsMono"
  ]; };


  etesync-dav = prev.callPackage ../packages/etesync-dav {};

  # OpenSSL 1.0 for Aundroid Auto emilator
  openssl_1_0 = prev.openssl.overrideAttrs (oldAttrs: rec {
    pname = "openssl";
    version = "1.0.2u";
    sha256 = "sha256-7NDG/7ST3QZwfTixS7TYwiiLtwM3NWBladj5D4lmnRY=";
    patches = [];
    withDocs = false;
    src = prev.fetchurl {
      url = "https://www.openssl.org/source/${pname}-${version}.tar.gz";
      inherit sha256;
    };
    outputs = ["bin" "dev" "out" "man"];
  });

  android-fhs-env = prev.callPackage ../packages/android-fhs-env {};

  androidStudioPackages = prev.recurseIntoAttrs
    (prev.callPackage ../packages/android-studio { });

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = prev.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: rec {
    patches = [
      ../packages/xkb/custom-us-hbs.patch
    ];
  });
}
