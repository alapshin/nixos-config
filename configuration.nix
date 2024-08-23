{
  self,
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  ...
}:
{
  nixpkgs = {
    inherit pkgs;
  };

  system = {
    stateVersion = "23.11";
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
