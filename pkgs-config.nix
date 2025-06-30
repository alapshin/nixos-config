{ lib }:
{
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

        "idea"
        "datagrip"
        "androidsdk"
        "android-sdk"
        "android-studio"

        "pritunl-client"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
