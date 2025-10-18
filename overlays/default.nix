{ inputs, ... }:
{
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # When applied, the  nixpkgs set from pull-request (declared in the flake inputs)
  # will be accessible through 'pkgs.<pull-request-name>'
  development = final: prev: {
  };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    jetbrains = prev.jetbrains // {
      jdk = prev.jetbrains.jdk-no-jcef;
    };

    firefox =
      if prev.stdenv.hostPlatform.isLinux then
        prev.firefox
      else
        inputs.nixpkgs-pinned.legacyPackages."${prev.system}".firefox;
    firefox-unwrapped =
      if prev.stdenv.hostPlatform.isLinux then
        prev.firefox-unwrapped
      else
        inputs.nixpkgs-pinned.legacyPackages."${prev.system}".firefox-unwrapped;

    open-webui = prev.open-webui.overridePythonAttrs (oldAttrs: rec {
      dependencies = oldAttrs.dependencies ++ oldAttrs.optional-dependencies.postgres;
    });
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyfinal: pyprev: {
        autobean = pyfinal.callPackage ../packages/autobean { };
      })
    ];
  };
}
