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
      "xray/vless_private_key" = {
        restartUnits = [ "xray.service" ];
      };
      "xray/shadowsocks_password" = {
        restartUnits = [ "xray.service" ];
      };
    };
    templates."xray-config.json".content = builtins.readFile (
      pkgs.substituteAll {
        src = ./xray-config.json;
        vless_user_id = config.sops.placeholder."xray/vless_user_id";
        vless_private_key = config.sops.placeholder."xray/vless_private_key";
        shadowsocks_password = config.sops.placeholder."xray/shadowsocks_password";
      }
    );
  };

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates."xray-config.json".path;
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ 1080 ];
      allowedTCPPorts = [
        1080
        8443
      ];
    };
  };

  systemd.services.xray = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.xray.package}/bin/xray -config \${CREDENTIALS_DIRECTORY}/config.json";
      LoadCredential = "config.json:${config.sops.templates."xray-config.json".path}";
    };
  };
}
