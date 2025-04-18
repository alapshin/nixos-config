{
  pkgs,
  osConfig,
  ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
