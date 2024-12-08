{
  dotfileDir,
  sharedModules,
}:
{

  home-manager = {
    verbose = true;
    # Use global pkgs configured via nixpkgs.* options
    useGlobalPkgs = true;
    # Install user packages to /etc/profiles instead.
    # Necessary for nixos-rebuild build-vm to work.
    useUserPackages = true;
    extraSpecialArgs = {
      inherit dotfileDir;
    };
    sharedModules = sharedModules;
  };
}
