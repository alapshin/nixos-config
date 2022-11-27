{
  pkgs,
  osConfig,
  dotfileDir,
  ...
}: {
  programs.thunderbird = {
    enable = true;

    profiles = {
      default = {
        isDefault = true;
        settings = {
        };
      };
    };
  };
}
