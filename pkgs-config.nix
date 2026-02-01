{ lib }:
{
  allowAliases = false;

  android_sdk.accept_license = true;
  permittedInsecurePackages = [
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
        # Self-hosted
        "changedetection-io"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
