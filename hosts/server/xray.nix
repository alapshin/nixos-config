{ config
  , lib
  , pkgs
  , ...
}: {
  sops = {
    secrets = {
      "xray/config.json" = {
        format = "binary";
        sopsFile = ./secrets/xray-config.json;
      };
    };
  };
  services.xray = {
    enable = true;
    settingsFile = config.sops.secrets."xray/config.json".path;
  };

  systemd.services.xray = {
    serviceConfig = {
      LoadCredential = "config.json:${config.services.xray.settingsFile}";
      ExecStart = lib.mkForce "${config.services.xray.package}/bin/xray -config \${CREDENTIALS_DIRECTORY}/config.json";
    };
  };
}
