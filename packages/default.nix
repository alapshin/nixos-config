{ final
, prev
,
}: {
  android-fhs-env = final.callPackage ./android-fhs-env { };

  androidStudioPackages =
    final.recurseIntoAttrs
      (final.callPackage ./android-studio { });

  customHunspellDicts = prev.recurseIntoAttrs (prev.callPackages ./hunspell/dictionaries.nix { });

  keepassxc-autostart = prev.makeAutostartItem {
    name = "KeePassXC";
    package = prev.keepassxc;
    srcPrefix = "org.keepassxc.";
  };

  telegram-autostart = prev.makeAutostartItem {
    name = "telegram.desktop";
    package = prev.telegram-desktop;
    srcPrefix = "org.";
  };

  thunderbird-autostart = prev.makeAutostartItem {
    name = "thunderbird";
    package = prev.thunderbird;
  };

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = final.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: rec {
    patches = [
      ./xkb/custom-us-hbs.patch
    ];
  });

  firefox-addons = final.recurseIntoAttrs (final.callPackage ./firefox-addons { });

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (python-final: python-prev: {
        beanprice = python-final.callPackage ./beanprice { };
        beancount = python-prev.beancount.overridePythonAttrs (oldAttrs: {
          # Rename old bean-price binary to avoid confict with standalone version
          postPatch = ''
            substituteInPlace setup.py --replace 'bean-price' 'bean-price-legacy'
          '';
        });
        beancount-plugin-utils = python-final.callPackage ./beancount-plugin-utils { };
      })
    ];
}
