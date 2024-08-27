{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.backup;

  inherit (lib)
    types
    attrsets
    mkIf
    mkOption
    mkEnableOption
    nameValuePair
    ;

  hostname = config.networking.hostName;
  mkBorgJob =
    opts:
    {
      repo = "ssh://${cfg.user}@${cfg.host}:${cfg.port}/./borgbackup/${hostname}";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.passphraseFile}";
      };
      compression = "auto,lzma";

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 1;
      };

      startAt = "*-*-* 21:00:00";
      persistentTimer = true;

      extraInitArgs = "--verbose";
      extraCreateArgs = "--verbose --stats";

      environment = {
        BORG_RSH = "ssh -i ${cfg.sshKeyFile}";
      };
    }
    // opts;
in
{
  options.services.backup = {
    enable = mkEnableOption "backup";
    user = mkOption {
      type = types.str;
      description = "Username for the SSH remote host.";
    };

    host = mkOption {
      type = types.str;
      description = "Hostname of the SSH remote host.";
    };

    port = mkOption {
      type = types.port;
      default = 22;
      description = "Port of the SSH remote host.";
      apply = toString;
    };

    sshKeyFile = mkOption {
      type = types.path;
      description = ''
        Path to the ssh private key used to access repository.
      '';
    };

    passphraseFile = mkOption {
      type = types.path;
      example = "/run/secrets/borg-passphrase";
      description = ''
        Path to the passphrase used to encrypt backups in the repository.
      '';
    };

    borg = mkOption {
      type = types.submodule {
        options = {
          jobs = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  paths = mkOption {
                    type = types.listOf types.path;
                    default = [ ];
                    description = "Paths to include in the backup.";
                  };
                };
              }
            );
          };
        };
      };
    };

  };

  config = mkIf cfg.enable {
    services.borgbackup = {
      jobs = attrsets.mapAttrs (job: opts: mkBorgJob opts) cfg.borg.jobs;
    };
  };
}
