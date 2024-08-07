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

  fava = final.callPackage ./fava { };

  firefox-addons = final.recurseIntoAttrs (final.callPackage ./firefox-addons { });

  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (python-final: python-prev: {
        autobean = python-final.callPackage ./autobean { };
        beancount3 = python-final.callPackage ./beancount { };
        # Install standalone beanprice
        beanprice = python-final.callPackage ./beanprice { };
        beanquery = python-final.callPackage ./beanquery { };
        beancount2 = python-prev.beancount;
        beancount-plugin-utils = python-final.callPackage ./beancount-plugin-utils { };
      })
    ];
}
