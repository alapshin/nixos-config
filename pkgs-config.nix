{ lib }:
{
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    "jitsi-meet-1.0.8792"
    # Used by electrum
    "python3.13-ecdsa-0.19.1"
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
        "claude-code"
        "gemini-cli"
        # Jetbrains
        "idea"
        "pycharm"
        "jetbrains-toolbox"
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

        # Darwin utils
        "mos"
        "keka"
        "betterdisplay"
        # Used for work
        "zoom"
        "pritunl-client"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
