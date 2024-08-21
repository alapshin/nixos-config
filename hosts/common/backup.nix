{
  lib,
  pkgs,
  config,
  ...
}:
let
  user = "u399502";
  host = "${user}.your-storagebox.de";
  jobname = "default";
  hostname = config.networking.hostName;
in
{
  sops.secrets = {
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
    ${jobname} = {
      repo = "ssh://${user}@${host}:23/./borgbackup/${hostname}";
      paths = [ ];
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

      startAt = "*-*-* 21:00:00";
      persistentTimer = true;

      environment = {
        BORG_RSH = "ssh -i ${config.sops.secrets."borg/borg_ed25519".path}";
      };
    };
  };

  systemd.timers."borgbackup-job-${jobname}".wants = [ "network-online.target" ];

  programs.ssh.knownHosts = {
    "${host}" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
    };
  };
}
