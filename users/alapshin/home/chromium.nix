{
  pkgs,
  osConfig,
  ...
}:
{
  programs.chromium = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    package = pkgs.ungoogled-chromium;
  };
}
