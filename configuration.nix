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
  nixpkgs.pkgs = pkgs;

  system = {
    stateVersion = "24.11";
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
