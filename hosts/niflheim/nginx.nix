{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.nginx = {
    enable = false;
    defaultHTTPListenPort = 10080;
    defaultListenAddresses = [
      "127.0.0.1"
    ];
  };
}
