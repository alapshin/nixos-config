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
  home.file = {
    ".thunderbird/default/user.js".source = "${dotfileDir}/thunderbird/user.js";
  };
}
