{ final
, prev
,
}: {
  # pricehist = pkgs.callPackage ./pricehist {
  #   buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
  # };

  android-fhs-env = final.callPackage ./android-fhs-env { };

  androidStudioPackages =
    final.recurseIntoAttrs
      (final.callPackage ./android-studio { });

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
      })
    ];
}
