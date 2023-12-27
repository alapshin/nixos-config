{ config
, lib
, pkgs
, ...
}: {
  sops = {
    secrets = {
      "xray/vless_private_key" = {
      };
      "xray/shadowsocks_password" = {
      };
    };
    templates."xray-config.json".content = builtins.readFile (pkgs.substituteAll {
      src = ./xray-config.json;
      vless_private_key = config.sops.placeholder."xray/vless_private_key";
      shadowsocks_password = config.sops.placeholder."xray/shadowsocks_password";
    });
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
