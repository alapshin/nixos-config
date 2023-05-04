{pkgs}: {
  android-fhs-env = pkgs.callPackage ./android-fhs-env {};

  androidStudioPackages =
    pkgs.recurseIntoAttrs
    (pkgs.callPackage ./android-studio {});

  # See nixos/modules/services/x11/extra-layouts.nix
  # xkeyboard-config with customized Serbo-Croatian variant of US layout
  xkbconfig_custom = pkgs.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: rec {
    patches = [
      ./xkb/custom-us-hbs.patch
    ];
  });

  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./firefox-addons {});
}
