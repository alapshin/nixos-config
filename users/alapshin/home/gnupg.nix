{
  pkgs,
  config,
  osConfig,
  ...
}: {
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentryFlavor = "qt";
  };
}
