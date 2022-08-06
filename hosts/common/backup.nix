{
  config,
  pkgs,
  ...
}: {
    services.borgbackup.jobs = {
        borgbase = {
            paths = [
                "/home/alapshin/calibre"
                "/home/alapshin/Documents"
                "/home/alapshin/Pictures"
                "/home/alapshin/Videos"
                "/home/alapshin/Syncthing"
            ];
            repo = "rm4i22x5@rm4i22x5.repo.borgbase.com:repo";
            encryption = {
                mode = "keyfile-blake2";
                passCommand = "cat /run/secrets/borg/encryption_passphrase";
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
                BORG_RSH = "ssh -i /run/secrets/borg/borgbase_ed25519";
                BORG_KEYS_DIR = "/run/secrets/borg/keys";
            };
        };
    };
}
