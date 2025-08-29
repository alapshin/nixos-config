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

      max-cache-ttl = 28800;
      default-cache-ttl = 28800;
      pinentry-mode = "loopback";
    };
  };
  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      allow-loopback-pinentry
    '';
    pinentry.package = pkgs.pinentry-tty;
  };
}
