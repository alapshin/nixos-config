{
  pkgs,
  config,
  ...
}:
{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    settings = {
      keyid-format = "long";
      with-keygrip = true;
      with-key-origin = true;
      with-fingerprint = true;
      with-subkey-fingerprint = true;
    };
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
  };
}
