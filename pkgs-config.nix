{ lib }:
{
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];
  allowUnfreePredicate =
    pkg:
    let
      name = lib.getName pkg;
      prefixes = [
        "slack"
        "steam"
        "nvidia"

        "drawio"
        "open-webui"
        "languagetool"

        "idea"
        "cursor"
        "claude-code"
        "gemini-cli"
        # Android stuff
        "androidsdk"
        "android-sdk"
        "android-studio"
        "build-tools"
        "cmake"
        "cmdline-tools"
        "emulator"
        "ndk"
        "platforms"
        "platform-tools"
        "sources"
        "system-image"
        "tools"

        "pritunl-client"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
