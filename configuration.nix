{
  self,
  lib,
  pkgs,
  ...
}:
{
  system = {
    stateVersion = if pkgs.stdenv.hostPlatform.isLinux then "24.11" else 6;
    configurationRevision = lib.mkIf (self ? rev) self.rev;
  };

  # Various nix utils
  environment.systemPackages = with pkgs; [
    manix
    nix-index
    nix-prefetch-git
    nix-prefetch-github
    nixfmt-rfc-style
  ];
}
