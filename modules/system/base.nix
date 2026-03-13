{ inputs, ... }:
{
  flake.modules.nixos.base =
    {
      self,
      lib,
      pkgs,
      ...
    }:
    {
      system.stateVersion = "24.11";
      system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      environment.systemPackages = with pkgs; [
        manix
        nixfmt
        nix-index
        nix-prefetch-git
        nix-prefetch-github
      ];
    };

  flake.modules.darwin.base =
    {
      self,
      lib,
      pkgs,
      ...
    }:
    {
      system.stateVersion = 6;
      system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      environment.systemPackages = with pkgs; [
        manix
        nixfmt
        nix-index
        nix-prefetch-git
        nix-prefetch-github
      ];
    };
}
