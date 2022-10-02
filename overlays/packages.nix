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

  electrum = prev.electrum.overrideAttrs(oldAttrs: rec {
    postPatch = ''
      # make compatible with protobuf4 by easing dependencies ...
      substituteInPlace ./contrib/requirements/requirements.txt \
        --replace "protobuf>=3.12,<4" "protobuf>=3.12"
      # ... and regenerating the paymentrequest_pb2.py file
      protoc --python_out=. electrum/paymentrequest.proto
    '';
  });

  etesync-dav = prev.callPackage ../packages/etesync-dav {};

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
}
