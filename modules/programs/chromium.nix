{ ... }:
{
  flake.modules.homeManager.chromium =
    {
      pkgs,
      ...
    }:
    {
      programs.chromium = {
        enable = pkgs.stdenv.hostPlatform.isLinux;
        package = pkgs.ungoogled-chromium;
      };
    };
}
