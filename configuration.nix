{
  config,
  lib,
  inputs,
  pkgs,
  self,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = [
      "nixpkgs=${inputs.nixos}"
    ];
    registry = {
      nixos.flake = inputs.nixos;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  nixpkgs = {
    pkgs = pkgs;
  };

  system = {
    stateVersion = "22.05";
    configurationRevision = lib.mkIf (self ? rev) self.rev;
  };

  # Various nix utils
  environment.systemPackages = with pkgs; [
    alejandra
    nix-index
    nix-prefetch-git
    nix-prefetch-github
  ];
}
