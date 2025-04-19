{ final, prev }:
{
  monica = prev.callPackage ./monica { };
  cuesplit = prev.callPackage ./cuesplit { };

  androidComposition = prev.callPackage ./androidenv { };

  androidStudioPackages = prev.recurseIntoAttrs (prev.callPackage ./android-studio { });
  android-studio-stable-with-sdk = (
    prev.androidStudioPackages.stable.withSdk final.androidComposition.androidsdk
  );

  firefox-addons = prev.recurseIntoAttrs (prev.callPackage ./firefox-addons { });

  customHunspellDicts = prev.recurseIntoAttrs (prev.callPackages ./hunspell/dictionaries.nix { });

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = prev.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: {
    patches = [ ./xkb/custom-us-hbs.patch ];
  });
}
