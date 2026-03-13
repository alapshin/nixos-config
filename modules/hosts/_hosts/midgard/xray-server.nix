{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops = {
    secrets = {
      "xray/vless_user_id" = {
        restartUnits = [ "xray.service" ];
      };
      "xray/vless_private_key" = {
        restartUnits = [ "xray.service" ];
      };
    };
    templates."xray-config.json".content =
      builtins.replaceStrings
        [
          "@vless_user_id@"
          "@vless_private_key@"
        ]
        [
          config.sops.placeholder."xray/vless_user_id"
          config.sops.placeholder."xray/vless_private_key"
        ]
        (builtins.readFile ./xray-config.jsonc);
    templates."xray-config.json".restartUnits = [ "xray.service" ];
  };

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates."xray-config.json".path;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        443
        8443
      ];
    };
  };
}
