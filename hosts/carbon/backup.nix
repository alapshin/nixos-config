{ config, ... }:
let
  storagebox = "u399502.your-storagebox.de";
in
{

  sops.secrets = {
    "borg/keyfile" = {
      format = "binary";
      sopsFile = ./secrets/borg/keyfile;
    };
    "borg/passphrase" = {
      sopsFile = ./secrets/borg/passphrase.yaml;
    };
    "borg/borg_ed25519" = {
      mode = "0600";
      format = "binary";
      sopsFile = ./secrets/borg/borg_ed25519;
    };
    "borg/borg_ed25519.pub" = {
      mode = "0600";
      format = "binary";
      sopsFile = ./secrets/borg/borg_ed25519.pub;
    };
  };
  services.borgbackup.jobs = {
    "home" = {
      paths = [
        "/home/alapshin/calibre"
        "/home/alapshin/Documents"
        "/home/alapshin/Syncthing"
      ];
      repo = "ssh://u399502@${storagebox}:23/./borgbackup/carbon";
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

  systemd.timers."borgbackup-job-home".wants = [ "network-online.target" ];

  programs.ssh.knownHosts = {
    "${storagebox}" = {
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
    };
  };
}
