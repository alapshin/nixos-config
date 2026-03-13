{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.android =
        let
          buildToolsVersion = "36.0.0";
          androidComposition = pkgs.androidComposition;
        in
        pkgs.mkShell rec {
          buildInputs = [ androidComposition.androidsdk ];
          ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
          shellHook = ''
            echo "sdk.dir=${androidComposition.androidsdk}/libexec/android-sdk" > local.properties
          '';
        };
    };
}
