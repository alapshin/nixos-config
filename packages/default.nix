{ final, prev }:
{
  monica = prev.callPackage ./monica { };
  cuesplit = prev.callPackage ./cuesplit { };
  sandbox-runtime = prev.callPackage ./sandbox-runtime { };

  androidComposition = prev.callPackage ./androidenv { };

  android-studio-stable-with-sdk = (
    prev.androidStudioPackages.stable.withSdk final.androidComposition.androidsdk
  );

  firefox-ui-fix = prev.callPackage ./firefox-ui-fix { };
  firefox-addons = prev.lib.recurseIntoAttrs (prev.callPackage ./firefox-addons { });

  customHunspellDicts = prev.lib.recurseIntoAttrs (prev.callPackages ./hunspell/dictionaries.nix { });

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = prev.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: {
    patches = [ ./xkb/custom-us-hbs.patch ];
  });
}
