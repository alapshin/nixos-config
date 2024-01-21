{ config
, pkgs
, ...
}: {
  services.borgbackup.jobs = {
    "carbon" = {
      paths = [
        "/home/alapshin/calibre"
        "/home/alapshin/Documents"
        "/home/alapshin/Syncthing"
      ];
      repo = "borg@alapshin.com:.";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      };
      compression = "auto,lzma";

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 1;
      };

      startAt = "*-*-* 12:00:00";
      persistentTimer = true;

      environment = {
        BORG_RSH = "ssh -i ${config.sops.secrets."borg/borg_ed25519".path}";
        BORG_KEY_FILE = config.sops.secrets."borg/keyfile".path;
      };
    };
  };

  systemd.timers."borgbackup-job-carbon".wants = [ "network-online.target" ];
}
