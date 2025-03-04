{ lib }:
{
  android_sdk.accept_license = true;
  permittedInsecurePackages = [
    # Used by logseq
    "electron-27.3.11"
    # Used by Servarr apps
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
  ];
  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Used by only-office
      "corefonts"

      "drawio"
      "languagetool"

      "slack"

      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"

      "nvidia-x11"
      "nvidia-settings"

      "datagrip"
      "idea-ultimate"
      "android-studio-stable"
      "android-studio-beta"
      "android-studio-canary"
      "android-sdk-tools"
      "android-sdk-cmdline-tools"

    ];
}
