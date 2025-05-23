{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops = {
    secrets = {
      "xray/vless_user_id" = {
        restartUnits = [ "xray.service" ];
      };
      "xray/vless_public_key" = {
        restartUnits = [ "xray.service" ];
      };
    };
    templates."xray-config.json".content = builtins.readFile (
      pkgs.replaceVars ./xray-config.json {
        vless_user_id = config.sops.placeholder."xray/vless_user_id";
        vless_public_key = config.sops.placeholder."xray/vless_public_key";
      }
    );
  };

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates."xray-config.json".path;
  };

  systemd.services.xray = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.xray.package}/bin/xray -config \${CREDENTIALS_DIRECTORY}/config.json";
      LoadCredential = "config.json:${config.sops.templates."xray-config.json".path}";
    };
  };
}
