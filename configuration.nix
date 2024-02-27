{ self
, lib
, pkgs
, config
, inputs
, outputs
, ...
}: {
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.nix_2_19;
    settings = {
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

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
  ];
}
