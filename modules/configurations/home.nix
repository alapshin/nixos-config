{
  inputs,
  config,
  withSystem,
  ...
}:
{
  flake.homeConfigurations = {
    "alapshin@desktop" = withSystem "x86_64-linux" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.self.modules.generic.dotfiles
          config.flake.modules.homeManager.infra
          config.flake.modules.homeManager.alapshin
        ];
        extraSpecialArgs = {
          inherit inputs;
          osConfig = {
            networking.hostName = "desktop";
          };
        };
      }
    );

    "alapshin@macbook" = withSystem "aarch64-darwin" (
      { pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.self.modules.generic.dotfiles
          config.flake.modules.homeManager.infra
          config.flake.modules.homeManager.alapshin
        ];
        extraSpecialArgs = {
          inherit inputs;
          osConfig = {
            networking.hostName = "macbook";
          };
        };
      }
    );
  };
}
