# Helper module for borgbackup setup
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
    ;

  hostname = config.networking.hostName;
  # Create a borgbackup job using defaults
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

      startAt = "daily";
      persistentTimer = true;

      extraInitArgs = "--verbose";
      extraCreateArgs = "--verbose --stats";
      extraPruneArgs = "--verbose --stats";

      environment = {
        BORG_RSH = "ssh -i ${cfg.sshKeyFile}";
      };
    }
    // opts;

  # Returns the service name for a job (e.g., "borgbackup-job-myjob.service")
  jobNameToServiceName = name: "borgbackup-job-${name}";

  # Creates systemd service dependencies to run jobs sequentially.
  # First job has no dependencies, each subsequent job depends on the previous one
  # This is neccessary when jobs are using the same borg repository because borgbackup
  # keeps exclusive lock on repository while creating or deleting archives.
  # See https://borgbackup.readthedocs.io/en/stable/faq.html#can-i-backup-from-multiple-servers-into-a-single-repository
  createServiceDependencies =
    jobs:
    let
      jobNames = lib.attrNames jobs;
      prevJobNames = [ null ] ++ lib.init jobNames;

      mkServiceDep =
        prev: current:
        attrsets.nameValuePair (jobNameToServiceName current) {
          serviceConfig = {
            Type = "oneshot";
          };
          after = lib.lists.optional (prev != null) "${jobNameToServiceName prev}.service";
        };
    in
    builtins.listToAttrs (lib.lists.zipListsWith mkServiceDep prevJobNames jobNames);

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

  config = mkIf cfg.enable {
    # Configure services to run sequentially
    systemd.services = createServiceDependencies cfg.jobs;
    services.borgbackup.jobs = attrsets.mapAttrs (_name: mkBorgJob) cfg.jobs;
  };
}
