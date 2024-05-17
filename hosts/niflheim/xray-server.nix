{ config
, lib
, pkgs
, ...
}: {
  sops = {
    secrets = {
      "xray/wireguard_secret_key" = {
        restartUnits = [ "xray.service" ];
      };
    };
    templates."xray-config.json".content = builtins.readFile (pkgs.substituteAll {
      src = ./xray-config.json;
      wireguard_secret_key = config.sops.placeholder."xray/wireguard_secret_key";
    });
  };

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates."xray-config.json".path;
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ 1080 ];
      allowedTCPPorts = [ 1080 8443 ];
    };
  };

  systemd.services.xray = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.xray.package}/bin/xray -config \${CREDENTIALS_DIRECTORY}/config.json";
      LoadCredential = "config.json:${config.sops.templates."xray-config.json".path}";
    };
  };
}
