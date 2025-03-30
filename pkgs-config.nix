{ lib }:
{
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    # Used by Servarr apps
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
  ];
  allowUnfreePredicate =
    pkg:
    let
      name = lib.getName pkg;
      prefixes = [
        "drawio"
        "languagetool"

        "slack"
        "steam"
        "nvidia"

        "idea"
        "datagrip"
        "androidsdk"
        "android-sdk"
        "android-studio"
      ];
    in
    builtins.any (prefix: lib.strings.hasPrefix prefix name) prefixes;
}
