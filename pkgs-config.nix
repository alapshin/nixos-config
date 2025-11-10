{ lib }:
{
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    "jitsi-meet-1.0.8792"
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

        # AI tools
        "cursor"
        "claude-code"
        "gemini-cli"
        # Jetbrains IDEs
        "idea"
        "pycharm"
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

        # Darwin stuff
        "zoom"
        "keka"
        "betterdisplay"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
