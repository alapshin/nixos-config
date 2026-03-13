{
  inputs,
  config,
  withSystem,
  ...
}:
{
  flake.darwinConfigurations.macbook = withSystem "aarch64-darwin" (
    { pkgs, ... }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit pkgs;
      modules = [
        inputs.self.modules.generic.dotfiles
        config.flake.modules.darwin.host-macbook
        inputs.sops-nix.darwinModules.sops
        inputs.determinate.darwinModules.default
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              inputs.self.modules.generic.dotfiles
              inputs.self.modules.homeManager.infra
              inputs.self.modules.homeManager.secrets
            ];
          };
          # User home-manager config via Multi Context Aspect
          home-manager.users."andrei.lapshin" = {
            imports = [ inputs.self.modules.homeManager.alapshin ];
          };
        }
      ];
      specialArgs = {
        inherit inputs;
        self = config.flake;
      };
    }
  );
}
