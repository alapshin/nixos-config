{ lib, config, ... }:
let
  port = 8086;
in
{
  sops = {
    secrets = {
      "influxdb/admin_token" = {
        owner = "influxdb2";
      };
      "influxdb/admin_password" = {
        owner = "influxdb2";
      };
    };
  };

  services = {
    influxdb2 = {
      enable = true;
      settings = {
        http-bind-address = "127.0.0.1:${toString port}";
      };
      provision = {
        enable = true;
        initialSetup = {
          bucket = "initial";
          organization = "homelab";
          tokenFile = config.sops.secrets."influxdb/admin_token".path;
          passwordFile = config.sops.secrets."influxdb/admin_password".path;
        };
      };
    };

    webhost.applications."influxdb" = {
      auth = true;
      inherit port;
    };
  };
}
