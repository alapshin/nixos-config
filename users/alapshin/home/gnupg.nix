{ pkgs, config, ... }:
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
    pinentry.package = pkgs.pinentry-qt;
  };
}
