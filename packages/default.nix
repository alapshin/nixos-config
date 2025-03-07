{ final, prev }:
{
  androidComposition = final.callPackage ./androidenv { };

  androidStudioPackages = final.recurseIntoAttrs (final.callPackage ./android-studio { });
  android-studio-stable-with-sdk = (
    final.androidStudioPackages.stable.withSdk final.androidComposition.androidsdk
  );

  firefox-addons = final.recurseIntoAttrs (final.callPackage ./firefox-addons { });

  customHunspellDicts = prev.recurseIntoAttrs (prev.callPackages ./hunspell/dictionaries.nix { });

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = final.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: {
    patches = [ ./xkb/custom-us-hbs.patch ];
  });

  monica = final.callPackage ./monica { };
}
