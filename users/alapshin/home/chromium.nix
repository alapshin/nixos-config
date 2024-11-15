{
  pkgs,
  osConfig,
  dotfileDir,
  ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
