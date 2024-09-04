{ final, prev }:
{
  android-fhs-env = final.callPackage ./android-fhs-env { };

  androidStudioPackages = final.recurseIntoAttrs (final.callPackage ./android-studio { });

  firefox-addons = final.recurseIntoAttrs (final.callPackage ./firefox-addons { });

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

  super-productivity = prev.callPackage ./super-productivity { };
  super-productivity-autostart = prev.makeAutostartItem {
    name = "super-productivity";
    package = prev.super-productivity;
  };

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = final.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: {
    patches = [ ./xkb/custom-us-hbs.patch ];
  });

  beanprice = prev.python3.pkgs.callPackage ./beanprice { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {

      autobean = python-final.callPackage ./autobean { };
      beancount3 = python-final.callPackage ./beancount { };
      # Install standalone beanprice
      beanquery = python-final.callPackage ./beanquery { };
      beancount-plugin-utils = python-final.callPackage ./beancount-plugin-utils { };
    })
  ];
}
